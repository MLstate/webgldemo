
type Scene.objects = { cube: (float, float, float); id: hidden_id; color: ColorFloat.color } ;

type Scene.scene = { objs: list(Scene.objects); CPF: Fresh.next(hidden_id) };
type Scene.command = { add_cube; cube:Scene.objects } / { change_color; id: hidden_id; new_color: ColorFloat.color } / {move_object; id: hidden_id; where:(float, float, float) } / { delete_object; id: hidden_id } ;
type Scene.patch = { pid: patch_id;  command: Scene.command };

type Scene.Client.command = 
  { add_cube; where: {x: float; y: float; z:float } } 
/ { selection_change_color; new_color: ColorFloat.color } 
/ { selection_change; possible_target: option(hidden_id) } 
/ { possible_move; where: {x: float; y: float; z:float }}
/ { selection_delete };

type Scene.Client.scene = { selection: option(Scene.objects); others: Scene.scene };

type Modeler.tool = {selection} / {add_cube} ;

type Modeler.view = {m: mat4; clear_near_far: vec3 -> vec3};
type Modeler.views = {_YX: Modeler.view; _YZ: Modeler.view; _ZX: Modeler.view; _3D: Modeler.view};

type Modeler.modeler = {
  address: string;
  scene: Scene.Client.scene;
  tool: Modeler.tool;
  client_id: int;
  views: Modeler.views;
} ;

Scene = {{
  empty(F, client_id) : Scene.scene = { objs=List.empty; CPF=build_CPF(F, client_id) };

  CPF_change(scene, F, client_id) : Scene.scene = { scene with CPF=build_CPF(F, client_id) };

  cube(scene, pos) = {cube=pos; id=scene.CPF(); color=ColorFloat.random()};

  find_object(scene : Scene.scene, target_id) : option(Scene.objects) = List.find((z -> z.id == target_id), scene.objs);
  extract_object(scene, target_id) : (option(Scene.objects), Scene.scene) = 
    (target, rest) = List.extract_p((z -> z.id == target_id), scene.objs);
    (target, { scene with objs=rest });
  extract_object_by_pos(scene, nth) : (option(Scene.objects), Scene.scene) = 
    (target, rest) = List.extract(nth, scene.objs);
    (target, { scene with objs=rest });
  add_object(scene, object) : Scene.scene = { scene with objs=List.cons(object, scene.objs) };
  reinject_object(scene, oobject : option(Scene.objects)) : Scene.scene = Option.switch((an_o -> add_object(scene, an_o)), scene, oobject);

  @private apply_command(scene, command : Scene.command) : Scene.scene = match command with
    | {add_cube; ~cube } -> add_object(scene, cube)
    | {change_color; ~id; ~new_color} ->
      (otarget, scene) = extract_object(scene, id);
      f(an_o) = add_object(scene, { an_o with color=new_color });
      Option.switch(f, scene, otarget)
    | {move_object; ~where; ~id} ->
      (otarget, scene) = extract_object(scene, id);
      f(an_o) = add_object(scene, { an_o with cube=where });
      Option.switch(f, scene, otarget)
    | {delete_object; ~id} ->
      (_, scene) = extract_object(scene, id);
      scene
    end ;

  apply_patch(scene, patch : Scene.patch) : Scene.scene = apply_command(scene, patch.command) ;
  apply_patchs(scene, patchs : list(Scene.patch)) : Scene.scene = List.fold((p, acc -> apply_patch(acc, p)), patchs, scene);

}} ;

`Scene.Client` = {{

  @private @client CHF : Fresh.next(int) = Fresh.client((i -> i : int));

  load(scene : Scene.scene, client_id) : Scene.Client.scene =
    scene = Scene.CPF_change(scene, CHF, client_id);
    (selection, others) = Scene.extract_object_by_pos(scene, 0);
    { ~selection; ~others };

  empty(client_id) : Scene.Client.scene = 
    load(Scene.empty(CHF, client_id), client_id);

  @private get_scene(scene : Scene.Client.scene) : Scene.scene = Option.switch((sel -> Scene.add_object(scene.others, sel)), scene.others, scene.selection);

  command_to_scene_patch(scene, cmd : Scene.Client.command) : option(Scene.patch) = 
    match cmd with
    | { add_cube; ~where } -> 
      command = { add_cube; cube={ cube=(where.x, where.y, where.z); color=ColorFloat.random(); id=scene.others.CPF() } } : Scene.command;
      Option.some({ pid=scene.others.CPF(); ~command})
    | { selection_change_color; ~new_color } -> 
      f(sel) = { pid=scene.others.CPF(); command={ change_color; id=sel.id ; ~new_color } };
      Option.map(f, scene.selection)
    | { possible_move; ~where } ->
      f(sel) = { pid=scene.others.CPF(); command={ move_object; where=(where.x, where.y, where.z); id=sel.id } };
      Option.map(f, scene.selection)
    | { selection_change; ... } -> Option.none
    | { selection_delete } -> 
      f(sel) = { pid=scene.others.CPF(); command={ delete_object; id=sel.id } };
      Option.map(f, scene.selection)
    end;

  selection_change_low(scene, possible_target) : Scene.Client.scene =
    match (possible_target, scene.selection) with
    | ({none}, {none}) -> scene
    | ({none}, {~some}) -> { scene with selection=Option.none; others=Scene.add_object(scene.others, some) }
    | ({~some}, osel) -> 
      //we put back the sel with others
      others = Option.switch((sel -> Scene.add_object(scene.others, sel)), scene.others, osel);
      //we retrieve the new sel
      (new_sel, others) = Scene.extract_object(others, some);
      do if Option.is_none(new_sel) then Log.error("Scene", "a selection failed to find the corresponding object");
      { scene with selection=new_sel; ~others }
    end ;

  write_patch(scene, patch : Scene.patch) : Scene.Client.scene =
    (selection, others) =
      base = Scene.apply_patch(get_scene(scene), patch);
      g(sel) = Scene.extract_object(base, sel.id);
      Option.switch(g, (Option.none, base), scene.selection);
    { scene with ~others; ~selection };

  apply_command(scene, command : Scene.Client.command) : (Scene.Client.scene, option(Scene.patch)) =
    match command with
    | { selection_change; ~possible_target } -> (selection_change_low(scene, possible_target), Option.none)
    | _ -> 
      command = command_to_scene_patch(scene, command);
      do Log.debug("apply_command", "{command} \t {scene.selection}");
      f(p) = write_patch(scene, p);
      (Option.switch(f, scene, command), command)
    end ;

  others_add_cube(scene, where) : (Scene.Client.scene, option(Scene.patch)) = apply_command(scene, {add_cube; ~where});

  selection_change(scene, possible_target) : (Scene.Client.scene, option(Scene.patch)) = apply_command(scene, {selection_change; ~possible_target});

  selection_change_color(scene, new_color) : (Scene.Client.scene, option(Scene.patch)) = apply_command(scene, {selection_change_color; ~new_color});
  
  do_possible_move(scene, where) : (Scene.Client.scene, option(Scene.patch)) = apply_command(scene, { possible_move; ~where });

  selection_delete(scene) : (Scene.Client.scene, option(Scene.patch)) = apply_command(scene, {selection_delete});

}} ;

Modeler = {{
  load(scene, scene_url, client_id, ratio_h_w) : Modeler.modeler =
    g(rot, scaler) =
      tmp = mat4.create();
      tmp_x = 1.;
      do mat4.ortho(-tmp_x, tmp_x, -ratio_h_w, ratio_h_w, -10., 10., tmp);
      tmp = rot(tmp);
      mat4.scale(tmp, vec3.from_public(scaler), tmp);
    tmp_scaler = 1. / 10.;
    _YX = { m=g(identity, (tmp_scaler, tmp_scaler, 1.0)); clear_near_far=(pos -> { pos with f3=0.0 }) };  // we want the left border to be at -10, and the rigth at 10
    _YZ = { m=g(m -> mat4.rotateY(m, (90. * Math.PI / 180.), m), (1.0, tmp_scaler, tmp_scaler)); clear_near_far=(pos -> { pos with f1=0.0 }) };
    _ZX = { m=g(m -> mat4.rotateX(m, (90. * Math.PI / 180.), m), (tmp_scaler, 1.0, tmp_scaler)); clear_near_far=(pos -> { pos with f2=0.0 }) };
    _3D =
      tmp_pMatrix = mat4.create();
      do mat4.perspective(45., 1. / ratio_h_w, 0.1, 100.0, tmp_pMatrix);
      c = mat4.create() ;
      do mat4.lookAt(vec3.from_public((10.0, 5.0, 15.0)), vec3.from_public((0., 0., 0.)), vec3.from_public((0.0, 1.0, 0.0)), c);
      do mat4.multiply(tmp_pMatrix, c, tmp_pMatrix);
      { m=tmp_pMatrix; clear_near_far=(pos -> { pos with f2=0.0 }) } ;
    views = { ~_YX; ~_YZ; ~_ZX; ~_3D };
    { address=scene_url; ~scene; tool={selection}; ~client_id; ~views } ;
  empty(scene_url, client_id, ratio_h_w) : Modeler.modeler = load(`Scene.Client`.empty(client_id), scene_url, client_id, ratio_h_w);

  tool_use(modeler, where, possible_target) : (Modeler.modeler, option(Scene.patch)) =
    do Log.info("Modeler", "using tool at ({where}) perhaps on the target: '{possible_target}' with tool: '{modeler.tool}'");
    match modeler.tool with
    | {add_cube} -> 
      (scene, opatch) = `Scene.Client`.others_add_cube(modeler.scene, where);
      ({ modeler with ~scene }, opatch)
    | {selection} -> 
      (scene, opatch) = `Scene.Client`.selection_change(modeler.scene, possible_target);
      ({ modeler with ~scene }, opatch)
    end ;

  tool_change(modeler, new_tool) : Modeler.modeler = { modeler with tool=new_tool };

  scene_change_selection_color(modeler, new_color) : (Modeler.modeler, option(Scene.patch)) = 
    (scene, opatch) = `Scene.Client`.selection_change_color(modeler.scene, new_color);
    ({ modeler with ~scene }, opatch);

  do_possible_move(modeler, where) : (Modeler.modeler, option(Scene.patch)) =
    match modeler.tool with
    | {selection} -> 
      (scene, opatch) = `Scene.Client`.do_possible_move(modeler.scene, where);
      ({ modeler with ~scene }, opatch)
    | {add_cube} -> (modeler, Option.none)
    end;

  write_patch(modeler, patch) : Modeler.modeler =
    if (modeler.client_id == get_client_id_from_patch_id(patch.pid)) then
      modeler
    else
      scene = `Scene.Client`.write_patch(modeler.scene, patch);
      { modeler with ~scene };

  scene_delete_selection(modeler) : (Modeler.modeler, option(Scene.patch)) =
    (scene, opatch) = `Scene.Client`.selection_delete(modeler.scene);
    ({ modeler with ~scene }, opatch);

}} ;

