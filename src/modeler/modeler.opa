
type Modeler = {
  address: string;
}

@client Modeler = {{

  @private on_message(state : Modeler, message) = match message with
    | {get_scene_and_do=f} -> f(List.empty)
    | _ -> {unchanged}
    end ;

  init(scene_url, canvas_sel, width, height) : outcome =
    (get_scene, set_scene) = 
      org_scene = [ {cube=(0.0, 0.0, -3.0); id=CHF()}, {cube=(3.0, 0.0, 0.0); id=CHF()}, {cube=(6.0, 0.0, 0.0); id=CHF()} ];
      ref = Mutable.make_client(org_scene);
      ((-> ref.get()), (new_scene -> ref.set(new_scene)));
    mouse_listener(e) = match e with
      | { mousedown; ~x; ~z } ->
        set_scene(List.cons({cube=(x, 0.0, z); id=CHF()}, get_scene()))
      end ;
    res = initGL(canvas_sel, width, height, get_scene, mouse_listener) ;
    match res with
    | {success} ->
      org_state = {
        address=scene_url
        } ;
      do ignore(SessionExt.make_with_getter(org_state, on_message));
      res
    | _ -> res
    end ;

}}
