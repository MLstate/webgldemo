
type Modeler.Shared.modeler = {
  scene: Scene.scene;
  address: string;
  clients: list(Central.Modelers.sync.message)
} ;

@server SHF : Fresh.next(int) = Fresh.server((i -> i : int));

@server `Modeler.Shared` = {{

  empty(server_id, address) : Modeler.Shared.modeler = 
    { scene=Scene.empty(SHF, server_id); ~address; clients=List.empty };

  add_client(modsha, client) = 
    { modsha with clients=List.cons(client, modsha.client) };

  apply_patch(modsha, patch) = 
    do Log.info("Modeler.Shared", "a patch as been apply for address '{modsha.address}'");
    { modsha with scene=Scene.apply_patch(modsha.scene, patch) };

}}


type Central.Modelers.state = { my_id: int; files: stringmap(Modeler.Shared.modeler) };
type Central.Modelers.message = { register; scene_url: string; sync_channel: channel(Central.Modelers.sync.message); client_id: int };

type Central.Modelers.sync.message = { load: Scene.scene };

@server `Central.Modelers` = {{
  empty() : Central.Modelers.state = { my_id=SHF(); files=StringMap.empty };

  find_file(state, address) = StringMap.get(address, state.files);

  update_file(state, address, f) : Central.Modelers.state =
    f(modsha) = 
      { state with files=StringMap.add(address, f(modsha), state.files) };
    Option.switch(f, state, find_file(state, address));

  apply_patch(state, address, patch) : Central.Modelers.state =
    f(modsha) = `Modeler.Shared`.apply_patch(modsha, patch);
    update_file(state, address, f);

}}

@server central_modelers : channel(Central.Modelers.message) =
  on_message(state : Central.Modelers.state, message) = match message with
    | { register; ~scene_url; ~sync_channel; ~client_id } ->
      do Log.info("CM", "register for url '{scene_url}'");
      base = match `Central.Modelers`.find_file(state, scene_url) with
        | {some=hit} -> hit
        | {none} ->
          scene = Scene.empty(SHF, state.my_id);
          scene = Scene.add_object(scene, Scene.cube(scene, (0.0, 0.0, -3.0)));
          scene = Scene.add_object(scene, Scene.cube(scene, (3.0, 0.0, 0.0)));
          scene = Scene.add_object(scene, Scene.cube(scene, (6.0, 0.0, 0.0)));
          { `Modeler.Shared`.empty(state.my_id, scene_url) with ~scene }
        end;
      do Session.send(sync_channel, { load=base.scene });
      { unchanged };
  Session.make_dynamic(`Central.Modelers`.empty(), on_message);
