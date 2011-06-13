
type Modeler = {
  address: string;
  scene: engine.scene
}

@client Modeler = {{

  @private on_message(state : Modeler, message) = match message with
    | {add_to_scene; ~where} ->
      { set={ state with scene=List.cons({cube=(where.x, 0.0, where.z); id=CHF()}, state.scene)}}
    | _ -> {unchanged}
    end ;

  init(scene_url, canvas_sel, width, height) : outcome =
    org_state = {
      address=scene_url; scene=[ {cube=(0.0, 0.0, -3.0); id=CHF()}, {cube=(3.0, 0.0, 0.0); id=CHF()}, {cube=(6.0, 0.0, 0.0); id=CHF()} ]
      } ;
    (channel, get_scene) =
      (channel, get_state) = SessionExt.make_with_getter(org_state, on_message);
      (channel, (-> get_state().scene)) ;
    mouse_listener(e) = match e with
      | { mousedown; ~x; ~z } -> Session.send(channel, {add_to_scene; where={~x; ~z}})
      end ;
    res = initGL(canvas_sel, width, height, get_scene, mouse_listener) ;
    match res with
    | {success} ->

      res
    | _ -> res
    end ;

}}
