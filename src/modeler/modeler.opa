
type Scene.objects = { cube: (float, float, float); id: hidden_id; color: ColorFloat.color } ;

type Scene.scene = { objs: list(Scene.objects); CPF: Fresh.next(patch_id) };
type Scene.command = { add_cube; where: {x: float; y: float; z:float } } / { change_color; id: hidden_id; new_color: ColorFloat.color };
type Scene.patch = { pid: patch_id;  command: Scene.command };

type Scene.Client.command = { add_cube; where: {x: float; y: float; z:float } } / { selection_change_color; new_color: ColorFloat.color } / { selection_change; possible_target: option(hidden_id) };

type Scene.Client.scene = { selection: option(Scene.objects); others: Scene.scene; CHF: Fresh.next(hidden_id) };

type Modeler.tool = {selection} / {add_cube} ;

type Modeler.modeler = {
  address: string;
  scene: Scene.Client.scene;
  tool: Modeler.tool;
} ;

Scene = {{
  empty(F, client_id) : Scene.scene = { objs=List.empty; CPF=build_CPF(F, client_id) };

  a_little_empty(F, client_id) : Scene.scene =
    c(pos) = {cube=pos; id=F(); color=ColorFloat.random()};
    { empty(F, client_id) with objs=[ c((0.0, 0.0, -3.0)), c((3.0, 0.0, 0.0)), c((6.0, 0.0, 0.0)) ] };

  find_object(scene : Scene.scene, target_id) : option(Scene.objects) = List.find((z -> z.id == target_id), scene.objs);
  extract_object(scene, target_id) : (option(Scene.objects), Scene.scene) = 
    (target, rest) = List.extract_p((z -> z.id == target_id), scene.objs);
    (target, { scene with objs=rest });
  extract_object_by_pos(scene, nth) : (option(Scene.objects), Scene.scene) = 
    (target, rest) = List.extract(nth, scene.objs);
    (target, { scene with objs=rest });
  add_object(scene, object) : Scene.scene = { scene with objs=List.cons(object, scene.objs) };
  reinject_object(scene, oobject : option(Scene.objects)) : Scene.scene = Option.switch((an_o -> add_object(scene, an_o)), scene, oobject);

  apply_command(scene, F, command : Scene.command) : Scene.scene = match command with
    | {add_cube; ~where} -> add_object(scene, {cube=(where.x, where.y, where.z); id=F(); color=ColorFloat.random()})
    | {change_color; ~id; ~new_color} ->
      (otarget, scene) = extract_object(scene, id);
      f(an_o) = add_object(scene, { an_o with color=new_color });
      Option.switch(f, scene, otarget)
    end ;

  apply_patch(scene, F, patch : Scene.patch) : Scene.scene = apply_command(scene, F, patch.command) ;
  apply_patchs(scene, F, patchs : list(Scene.patch)) : Scene.scene = List.fold((p, acc -> apply_patch(acc, F, p)), patchs, scene);

}} ;

`Scene.Client` = {{

  @client CHF : Fresh.next(hidden_id) = Fresh.client((i -> i : hidden_id));

  load(scene : Scene.scene) : Scene.Client.scene =
    (selection, others) = Scene.extract_object_by_pos(scene, 0);
    { ~selection; ~others; CHF=CHF };

  empty(client_id) : Scene.Client.scene = load(Scene.empty(CHF, client_id));

  @private get_scene(scene : Scene.Client.scene) : Scene.scene = Option.switch((sel -> Scene.add_object(scene.others, sel)), scene.others, scene.selection);

  command_to_scene_patch(scene, cmd : Scene.Client.command) : option(Scene.patch) = 
    match cmd with
    | { add_cube; ... } as command -> Option.some({ pid=scene.others.CPF(); ~command })
    | { selection_change_color; ~new_color } -> 
      f(sel) = { pid=scene.others.CPF(); command={ change_color; id=sel.id ; ~new_color } };
      Option.map(f, scene.selection)
    | { selection_change; ... } -> Option.none
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

  apply_command(scene, command : Scene.Client.command) : Scene.Client.scene =
    match command with
    | { selection_change; ~possible_target } -> selection_change_low(scene, possible_target)
    | _ -> 
      command = command_to_scene_patch(scene, command);
      do Log.debug("apply_command", "{command} \t {scene.selection}");
      f(p) =
        (selection, others) =
          base = Scene.apply_patch(get_scene(scene), scene.CHF, p);
          g(sel) = Scene.extract_object(base, sel.id);
          Option.switch(g, (Option.none, base), scene.selection);
        { scene with ~others; ~selection }
      Option.switch(f, scene, command)
    end ;
    
  others_add_cube(scene, where) : Scene.Client.scene = apply_command(scene, {add_cube; ~where});

  selection_change(scene, possible_target) : Scene.Client.scene = apply_command(scene, {selection_change; ~possible_target});

  selection_change_color(scene, new_color) : Scene.Client.scene = apply_command(scene, {selection_change_color; ~new_color});
    
}} ;

Modeler = {{
  empty(scene_url, client_id) : Modeler.modeler = { address=scene_url; scene=`Scene.Client`.empty(client_id); tool={selection} } ;

  tool_use(modeler, where, possible_target)  : Modeler.modeler = 
    do Log.info("Modeler", "using tool at ({where}) perhaps on the target: '{possible_target}' with tool: '{modeler.tool}'");
    match modeler.tool with
    | {add_cube} -> { modeler with scene=`Scene.Client`.others_add_cube(modeler.scene, where) }
    | {selection} -> { modeler with scene=`Scene.Client`.selection_change(modeler.scene, possible_target) }
    end ;

  tool_change(modeler, new_tool) : Modeler.modeler = { modeler with tool=new_tool };

  scene_change_selection_color(modeler, new_color) : Modeler.modeler = { modeler with scene=`Scene.Client`.selection_change_color(modeler.scene, new_color) };

}} ;

