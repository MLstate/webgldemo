
type Scene.objects = { cube: (float, float, float); id: hidden_id; color: ColorFloat.color } ;

type Scene.scene = list(Scene.objects);
type Scene.command = { add_cube; where: {x: float; y: float; z:float } } / { change_color; id: hidden_id; new_color: ColorFloat.color };
type Scene.patch = { pid: patch_id;  command: Scene.command };

type Scene.Client.command = { add_cube; where: {x: float; y: float; z:float } } / { selection_change_color; new_color: ColorFloat.color };

type Scene.Client.scene = { selection: option(Scene.objects); others: Scene.scene };

type Modeler.tool = {selection} / {add_cube} ;

type Modeler.modeler = {
  address: string;
  scene: Scene.Client.scene;
  tool: Modeler.tool
} ;

Scene = {{
  empty() : Scene.scene =
    c(pos) = {cube=pos; id=CHF(); color=ColorFloat.random()};
    [ c((0.0, 0.0, -3.0)), c((3.0, 0.0, 0.0)), c((6.0, 0.0, 0.0)) ];

  find_object(objects, target_id) : option(Scene.objects) = List.find((z -> z.id == target_id), objects);
  extract_object(objects, target_id) : (option(Scene.objects), list(Scene.objects)) = List.extract_p((z -> z.id == target_id), objects);
  add_object(objects, object) : list(Scene.objects) = List.cons(object, objects);

  selection_change_color(scene, new_color) : Scene.Client.scene = 
    match scene.selection with
    | {none} -> scene
    | {some=an_object} -> { scene with selection=Option.some({ an_object with color=new_color }) }
    end ;

  others_add_cube(scene, where) : Scene.Client.scene = { scene with others=List.cons({cube=(where.x, where.y, where.z); id=CHF(); color=ColorFloat.random()}, scene.others) };

  selection_change(scene, possible_target) : Scene.Client.scene =
    match (possible_target, scene.selection) with
    | ({none}, {none}) -> scene
    | ({none}, {~some}) -> { selection=Option.none; others=List.cons(some, scene.others) }
    | ({~some}, osel) -> 
      //we put back the sel with others
      others = Option.switch((sel -> List.cons(sel, scene.others)), scene.others, osel);
      //we retrieve the new sel
      (new_sel, others) = List.extract_p((elt -> elt.id == some), others);
      do if Option.is_none(new_sel) then Log.error("Scene", "a selection failed to find the corresponding object");
      { selection=new_sel; ~others }
    end ;

}} ;

`Scene.Client` = {{

  load(scene : Scene.scene) : Scene.Client.scene =
    (selection, others) = List.extract(0, scene);
    { ~selection; ~others };

  empty() : Scene.Client.scene = load(Scene.empty());

  command_to_scene_patch(scene, CPF, cmd : Scene.Client.command) : option(Scene.patch) = match cmd with
    | { add_cube; ... } as command -> Option.some({ pid=CPF(); ~command })
    | { selection_change_color; ~new_color } -> 
      f(sel) = { pid=CPF(); command={ change_color; id=sel.id ; ~new_color } };
      Option.map(f, scene.selection)
    end;
    
}} ;

Modeler = {{
  empty(scene_url) : Modeler.modeler = { address=scene_url; scene=`Scene.Client`.empty(); tool={selection} } ;

  tool_use(modeler, where, possible_target)  : Modeler.modeler = 
    do Log.info("Modeler", "using tool at ({where}) perhaps on the target: '{possible_target}' with tool: '{modeler.tool}'");
    match modeler.tool with
    | {add_cube} -> { modeler with scene=Scene.others_add_cube(modeler.scene, where) }
    | {selection} -> { modeler with scene=Scene.selection_change(modeler.scene, possible_target) }
    end ;

  tool_change(modeler, new_tool) : Modeler.modeler = { modeler with tool=new_tool };

  scene_change_selection_color(modeler, new_color) : Modeler.modeler = { modeler with scene=Scene.selection_change_color(modeler.scene, new_color) };

}} ;

