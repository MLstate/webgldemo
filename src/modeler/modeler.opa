

type Modeler.objects = { cube: (float, float, float); id: hidden_id } ;

type Modeler.scene = list(Modeler.objects) ;

type Modeler.mode = {selection} / {add_cube} ;

type Modeler = {
  address: string;
  scene: Modeler.scene;
  mode: Modeler.mode
} ;

Scene = {{ 
  empty() = [ {cube=(0.0, 0.0, -3.0); id=CHF()}, {cube=(3.0, 0.0, 0.0); id=CHF()}, {cube=(6.0, 0.0, 0.0); id=CHF()} ] ;

  add_cube(scene, where) = List.cons({cube=(where.x, 0.0, where.z); id=CHF()}, scene) ;

}}

@client GuiModeler = {{

  @private on_message(state : Modeler, message) = match message with
    | {click_on_scene; ~where} ->
      match state.mode with
      | {add_cube} -> { set={ state with scene=Scene.add_cube(state.scene, where) }}
      | {selection} -> {unchanged}
      end
    | _ -> {unchanged}
    end ;

  init(scene_url, canvas_sel, width, height) : outcome =
    org_state = {
      address=scene_url; scene=Scene.empty(); mode={selection}
      } ;
    (channel, get_scene) =
      (channel, get_state) = SessionExt.make_with_getter(org_state, on_message);
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
