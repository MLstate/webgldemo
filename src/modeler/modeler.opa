
type Modeler.objects = { cube: (float, float, float); id: hidden_id; color: ColorFloat.color } ;

type Modeler.scene = { selection: option(Modeler.objects); others: list(Modeler.objects) };

type Modeler.tool.mode = {selection} / {add_cube} ;

type Modeler.modeler = {
  address: string;
  scene: Modeler.scene;
  mode: Modeler.tool.mode
} ;

Scene = {{
  find_object(objects, target_id) : option(Modeler.objects) = List.find((z -> z.id == target_id), objects);
  extract_object(objects, target_id) : (option(Modeler.objects), list(Modeler.objects)) = List.extract_p((z -> z.id == target_id), objects);
  add_object(objects, object) : list(Modeler.objects) = List.cons(object, objects);

  change_selection_color(scene, new_color) : Modeler.scene = 
    match scene.selection with
    | {none} -> scene
    | {some=an_object} -> { scene with selection=Option.some({ an_object with color=new_color }) }
    end ;

  empty() : Modeler.scene =
    c(pos) = {cube=pos; id=CHF(); color=ColorFloat.random()};
    { selection=Option.some(c((0.0, 0.0, -3.0))); others=[ c((3.0, 0.0, 0.0)), c((6.0, 0.0, 0.0)) ] };

  add_cube(scene, where) = { scene with others=List.cons({cube=(where.x, where.y, where.z); id=CHF(); color=ColorFloat.random()}, scene.others) };

  selection(scene, possible_target) =
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
  empty(scene_url) = { address=scene_url; scene=Scene.empty(); mode={selection} } ;

  use_tool(modeler, where, possible_target) = 
    do Log.info("Modeler", "using tool at ({where}) perhaps on the target: '{possible_target}' in mode: '{modeler.mode}'");
    match modeler.mode with
    | {add_cube} -> { modeler with scene=Scene.add_cube(modeler.scene, where) }
    | {selection} -> { modeler with scene=Scene.selection(modeler.scene, possible_target) }
    end ;

  change_tool(modeler, new_mode) = { modeler with mode=new_mode };

}} ;

type GuiModeler.t = {
  modeler: Modeler.modeler;
  subjects: { 
    mode: subject(Modeler.tool.mode);
    selection: subject(option(Modeler.objects))
    }
} ;

@client GuiModeler = {{

  empty(scene_url) : GuiModeler.t = 
    modeler = Modeler.empty(scene_url);
    subjects = { mode=Observable.make(modeler.mode); selection=Observable.make(modeler.scene.selection) };
    { ~modeler; ~subjects };

  @private on_message(state : GuiModeler.t, message) = 
    set_modeler(modeler) = { set={ state with ~modeler } } ;
    set_subjects(subjects) = { set={ state with ~subjects } } ;
    set(state) = { set=state };
    match message with
    | {click_on_scene; ~where; ~possible_target} -> 
      modeler = Modeler.use_tool(state.modeler, where, possible_target);
      if Observable.get_state(state.subjects.selection) == modeler.scene.selection then
        set_modeler(modeler)
      else
        subjects = { state.subjects with selection=Observable.change_state(modeler.scene.selection, state.subjects.selection) };
        set({ ~subjects; ~modeler })
    | {change_tool=new_mode} ->
      modeler = Modeler.change_tool(state.modeler, new_mode);
      subjects = { state.subjects with mode=Observable.change_state(new_mode, state.subjects.mode) };
      set({ ~subjects; ~modeler })
    end ;

  setup_menu(parent_sel, channel, s_mode) : void =
    f(some_mode) = match some_mode with
      | {selection} -> (<>*Sel*</>, <>Cube</>)
      | {add_cube} -> (<>Sel</>, <>*Cube*</>)
      end ;
    (id_a, id_b) = (Random.string(7), Random.string(7));
    on_mode_change = 
      then_do(new_mode) = 
        (text_a, text_b) = f(new_mode);
        Dom.transform([#{id_a}<- text_a, #{id_b}<- text_b]);
      { si=(-> not(Dom.is_empty(#{id_a})) && not(Dom.is_empty(#{id_b}))); ~then_do; else_autoclean };
    do Observable.register(on_mode_change, s_mode);
    menu =
      s(x) = (_ -> Session.send(channel, {change_tool=x}));
      <p><a id=#{id_a} onclick={s({selection})} >.</a> | <a id=#{id_b} onclick={s({add_cube})} >.</a></p>;
    ignore(Dom.put_at_start(parent_sel, Dom.of_xhtml(menu)));

  setup_selection_view(parent_sel, s_selection) : void =
    id = Random.string(7);
    do
      f(some_selection) = match some_selection with
        | {none} -> <></>
        | {~some} -> <>{ "{some}" }</>
        end ;
      on_selection_change =
        then_do(new_selection) = Dom.transform([#{id}<- f(new_selection)]);
        { si=(->not(Dom.is_empty(#{id}))); ~then_do; else_autoclean };
      Observable.register(on_selection_change, s_selection);
    sel =
      <div id=#{id} ></div>;
    ignore(Dom.put_at_end(parent_sel, Dom.of_xhtml(sel)));

  
  init(scene_url, parent_sel:dom, width, height) : void =
    id_canvas_canvas = "canvas_canvas" ;
    fail_msg = 
      <>It seems that your browser and/or graphics card are incompatible with Webgl.<a href="http://www.khronos.org/webgl/wiki/Getting_a_WebGL_Implementation" >Learn a little more about webgl support</a></> ;
    and_do(_) =
      (channel, get_scene, get_subjects) =
        (channel, get_state) = SessionExt.make_with_getter(empty(scene_url), on_message);
        (channel, (-> get_state().modeler.scene), (->get_state().subjects)) ;
      mouse_listener(e) = match e with
        | { mousedown; ~pos; ~possible_target } -> Session.send(channel, {click_on_scene; where={x=pos.f1; y=pos.f2; z=pos.f3}; ~possible_target})
        end ;
      res = initGL(#{id_canvas_canvas}, width, height, get_scene, mouse_listener) ;
      if Outcome.is_failure(res) then ignore(Dom.put_replace(parent_sel, Dom.of_xhtml(fail_msg))) 
      else 
        the_subjects = get_subjects();
        do setup_menu(parent_sel, channel, the_subjects.mode);
        setup_selection_view(parent_sel, the_subjects.selection);
    base =
      <canvas width={width} height={height} id=#{id_canvas_canvas} onready={and_do} ></canvas>;
    ignore(Dom.put_inside(parent_sel, Dom.of_xhtml(base)));

}}
