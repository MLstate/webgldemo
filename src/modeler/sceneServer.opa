
type Modeler.Shared.modeler = {
  scene: Scene.scene;
  address: string;
  clients: list(channel(Central.Modelers.sync.message))
} ;

@server SHF : Fresh.next(int) = Fresh.server((i -> i : int));

@server `Modeler.Shared` = {{

  empty(server_id, address) : Modeler.Shared.modeler = 
    { scene=Scene.empty(SHF, server_id); ~address; clients=List.empty };

  add_client(modsha, client) : Modeler.Shared.modeler =
    do Session.send(client, { load=modsha.scene });
    { modsha with clients=List.cons(client, modsha.clients) };

  apply_patch(modsha, patch) : Modeler.Shared.modeler = 
    do Log.info("Modeler.Shared", "a patch as been apply for address '{modsha.address}'");
    do 
      f(c) = Session.send(c, { write_patch; ~patch});
      List.iter(f, modsha.clients);
    { modsha with scene=Scene.apply_patch(modsha.scene, patch) };

}}


type Central.Modelers.state = { my_id: int; files: stringmap(Modeler.Shared.modeler) };
type Central.Modelers.message = 
  { register; scene_url: string; sync_channel: channel(Central.Modelers.sync.message); client_id: int }
/ { apply_patch; patch: Scene.patch; address: string };

type Central.Modelers.sync.message = 
  { load: Scene.scene }
/ { write_patch; patch: Scene.patch };

@server `Central.Modelers` = {{
  empty() : Central.Modelers.state = { my_id=SHF(); files=StringMap.empty };

  find_file(state, address) = StringMap.get(address, state.files);

  get_file(state, address) : Modeler.Shared.modeler = match find_file(state, address) with
    | {some=hit} -> hit
    | {none} ->
      scene = Scene.empty(SHF, state.my_id);
      scene = Scene.add_object(scene, Scene.cube(scene, (0.0, 0.0, -3.0)));
      scene = Scene.add_object(scene, Scene.cube(scene, (3.0, 0.0, 0.0)));
      scene = Scene.add_object(scene, Scene.cube(scene, (6.0, 0.0, 0.0)));
      { `Modeler.Shared`.empty(state.my_id, address) with ~scene }
    end;

  update_file(state, address, f) : Central.Modelers.state =
    modsha = get_file(state, address);
    { state with files=StringMap.add(address, f(modsha), state.files) };

  apply_patch(state, address, patch) : Central.Modelers.state =
    f(modsha) = `Modeler.Shared`.apply_patch(modsha, patch);
    update_file(state, address, f);

}}

@server central_modelers : channel(Central.Modelers.message) =
  on_message(state : Central.Modelers.state, message) = match message with
    | { register; ~scene_url; ~sync_channel; client_id=_ } ->
      do Log.info("CM", "register for url '{scene_url}'");
      state = 
        up(modsha) = `Modeler.Shared`.add_client(modsha, sync_channel);
        `Central.Modelers`.update_file(state, scene_url, up);
      { set=state }
    | { apply_patch; ~patch; ~address } ->
      state = `Central.Modelers`.apply_patch(state, address, patch);
      { set=state }
    end;
  Session.make_dynamic(`Central.Modelers`.empty(), on_message);
