
type Modeler.objects = { cube: (float, float, float); id: hidden_id; color: ColorFloat.color } ;

type Modeler.scene = { selection: option(Modeler.objects); others: list(Modeler.objects) };

type Modeler.tool = {selection} / {add_cube} ;

type Modeler.modeler = {
  address: string;
  scene: Modeler.scene;
  tool: Modeler.tool
} ;

Scene = {{
  empty() : Modeler.scene =
    c(pos) = {cube=pos; id=CHF(); color=ColorFloat.random()};
    { selection=Option.some(c((0.0, 0.0, -3.0))); others=[ c((3.0, 0.0, 0.0)), c((6.0, 0.0, 0.0)) ] };

  find_object(objects, target_id) : option(Modeler.objects) = List.find((z -> z.id == target_id), objects);
  extract_object(objects, target_id) : (option(Modeler.objects), list(Modeler.objects)) = List.extract_p((z -> z.id == target_id), objects);
  add_object(objects, object) : list(Modeler.objects) = List.cons(object, objects);

  selection_change_color(scene, new_color) : Modeler.scene = 
    match scene.selection with
    | {none} -> scene
    | {some=an_object} -> { scene with selection=Option.some({ an_object with color=new_color }) }
    end ;

  others_add_cube(scene, where) : Modeler.scene = { scene with others=List.cons({cube=(where.x, where.y, where.z); id=CHF(); color=ColorFloat.random()}, scene.others) };

  selection_change(scene, possible_target) : Modeler.scene =
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

Modeler = {{
  empty(scene_url) : Modeler.modeler = { address=scene_url; scene=Scene.empty(); tool={selection} } ;

  tool_use(modeler, where, possible_target)  : Modeler.modeler = 
    do Log.info("Modeler", "using tool at ({where}) perhaps on the target: '{possible_target}' with tool: '{modeler.tool}'");
    match modeler.tool with
    | {add_cube} -> { modeler with scene=Scene.others_add_cube(modeler.scene, where) }
    | {selection} -> { modeler with scene=Scene.selection_change(modeler.scene, possible_target) }
    end ;

  tool_change(modeler, new_tool) : Modeler.modeler = { modeler with tool=new_tool };

  scene_change_selection_color(modeler, new_color) : Modeler.modeler = { modeler with scene=Scene.selection_change_color(modeler.scene, new_color) };

}} ;

