

type Modeler.objects = { cube: (float, float, float); id: hidden_id } ;

type Modeler.scene = list(Modeler.objects) ;

type Modeler.tool.mode = {selection} / {add_cube} ;

type Modeler.modeler = {
  address: string;
  scene: Modeler.scene;
  mode: Modeler.tool.mode
} ;

Scene = {{ 
  empty() = [ {cube=(0.0, 0.0, -3.0); id=CHF()}, {cube=(3.0, 0.0, 0.0); id=CHF()}, {cube=(6.0, 0.0, 0.0); id=CHF()} ] ;

  add_cube(scene, where) = List.cons({cube=(where.x, 0.0, where.z); id=CHF()}, scene) ;

}} ;

Modeler = {{
  empty(scene_url) = { address=scene_url; scene=Scene.empty(); mode={selection} } ;

  use_tool(modeler, where, possible_target) = 
    do Log.info("Modeler", "using tool at ({where.x},{where.z}) perhaps on the target: '{possible_target}'");
    match modeler.mode with
    | {add_cube} -> { modeler with scene=Scene.add_cube(modeler.scene, where) }
    | {selection} -> modeler
    end ;

  change_tool(modeler, new_mode) = { modeler with mode=new_mode };

}} ;

@client GuiModeler = {{

  empty(scene_url) = 
    modeler = Modeler.empty(scene_url);
    subjects = { mode=Observable.make(modeler.mode) };
    { ~modeler; ~subjects };

  @private on_message(state, message) = 
    set_modeler(modeler) = { set={ state with ~modeler } } ;
    set_subjects(subjects) = { set={ state with ~subjects } } ;
    set(state) = { set=state };
    match message with
    | {click_on_scene; ~where; ~possible_target} -> set_modeler(Modeler.use_tool(state.modeler, where, possible_target))
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
      { si=(->true); ~then_do; else_autoclean };
    do Observable.register(on_mode_change, s_mode);
    menu =
      s(x) = (_ -> Session.send(channel, {change_tool=x}));
      <p><a id=#{id_a} onclick={s({selection})} >.</a> | <a id=#{id_b} onclick={s({add_cube})} >.</a></p>;
    ignore(Dom.put_at_start(parent_sel, Dom.of_xhtml(menu)));
  
  init(scene_url, parent_sel:dom, width, height) : void =
    id_canvas_canvas = "canvas_canvas" ;
    fail_msg = 
      <>It seems that your browser and/or graphics card are incompatible with Webgl.<a href="http://www.khronos.org/webgl/wiki/Getting_a_WebGL_Implementation" >Learn a little more about webgl support</a></> ;
    and_do(_) =
      (channel, get_scene, get_subjects) =
        (channel, get_state) = SessionExt.make_with_getter(empty(scene_url), on_message);
        (channel, (-> get_state().modeler.scene), (->get_state().subjects)) ;
      mouse_listener(e) = match e with
        | { mousedown; ~x; ~z; ~possible_target } -> Session.send(channel, {click_on_scene; where={~x; ~z}; ~possible_target})
        end ;
      res = initGL(#{id_canvas_canvas}, width, height, get_scene, mouse_listener) ;
      if Outcome.is_failure(res) then ignore(Dom.put_replace(parent_sel, Dom.of_xhtml(fail_msg))) else setup_menu(parent_sel, channel, get_subjects().mode);
    base =
      <canvas width={width} height={height} id=#{id_canvas_canvas} onready={and_do} ></canvas>;
    ignore(Dom.put_inside(parent_sel, Dom.of_xhtml(base)));

}}
