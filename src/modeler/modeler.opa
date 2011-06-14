

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

  @private on_message(state : Modeler.modeler, message) = match message with
    | {click_on_scene; ~where; ~possible_target} -> { set=Modeler.use_tool(state, where, possible_target) }
    //| _ -> {unchanged}
    end ;

  init(scene_url, parent_sel:dom, width, height) : void =
    id_canvas_canvas = "canvas_canvas" ;
    fail_msg = 
      <>It seems that your browser and/or graphics card are incompatible with Webgl.<a href="http://www.khronos.org/webgl/wiki/Getting_a_WebGL_Implementation" >Learn a little more about webgl support</a></> ;
    base =
      <div />
      <canvas width={width} height={height} id=#{id_canvas_canvas} ></canvas>;
    do ignore(Dom.put_inside(parent_sel, Dom.of_xhtml(base)));
    (channel, get_scene) =
      (channel, get_state) = SessionExt.make_with_getter(Modeler.empty(scene_url), on_message);
      (channel, (-> get_state().scene)) ;
    mouse_listener(e) = match e with
      | { mousedown; ~x; ~z; ~possible_target } -> Session.send(channel, {click_on_scene; where={~x; ~z}; ~possible_target})
      end ;
    res = initGL(#{id_canvas_canvas}, width, height, get_scene, mouse_listener) ;
    if Outcome.is_failure(res) then ignore(Dom.put_replace(parent_sel, Dom.of_xhtml(fail_msg)));
}}
