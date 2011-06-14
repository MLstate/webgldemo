

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

  use_tool(modeler, where) = 
    match modeler.mode with
    | {add_cube} -> { modeler with scene=Scene.add_cube(modeler.scene, where) }
    | {selection} -> modeler
    end ;

}} ;

@client GuiModeler = {{

  @private on_message(state : Modeler.modeler, message) = match message with
    | {click_on_scene; ~where} -> { set=Modeler.use_tool(state, where) }
    | _ -> {unchanged}
    end ;

  init(scene_url, canvas_sel, width, height) : outcome =
    (channel, get_scene) =
      (channel, get_state) = SessionExt.make_with_getter(Modeler.empty(scene_url), on_message);
      (channel, (-> get_state().scene)) ;
    mouse_listener(e) = match e with
      | { mousedown; ~x; ~z } -> Session.send(channel, {click_to_scene; where={~x; ~z}})
      end ;
    res = initGL(canvas_sel, width, height, get_scene, mouse_listener) ;
    match res with
    | {success} ->

      res
    | _ -> res
    end ;

}}
