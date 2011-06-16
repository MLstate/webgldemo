
type Modeler.Shared.modeler = {
  scene: Scene.scene;
  address: string;
  clients: list(void)
} ;

@server SHF : Fresh.next(int) = Fresh.server((i -> i : int));

@server `Modeler.Shared` = {{

  empty(server_id) : Modeler.Shared.modeler = 
    { scene=Scene.empty(SHF, server_id); address=Random.string(8); clients=List.empty };

}}


type Central.Modelers.state = { my_id: int; files: stringmap(Modeler.Shared.modeler) };
type Central.Modelers.message = { register; scene_url: string; sync_channel: channel(Central.Modelers.sync.message); client_id: int };

type Central.Modelers.sync.message = { load: Scene.scene };

@server `Central.Modelers` = {{
  empty() : Central.Modelers.state = { my_id=SHF(); files=StringMap.empty };

}}

@server central_modelers : channel(Central.Modelers.message) =
  on_message(state, message) = match message with
    | { register; ~scene_url; ~sync_channel; ~client_id } ->
      do Log.info("CM", "register for url '{scene_url}'");
      base = Scene.empty(SHF, state.my_id);
      base = Scene.add_object(base, Scene.cube(base, (0.0, 0.0, -3.0)));
      base = Scene.add_object(base, Scene.cube(base, (3.0, 0.0, 0.0)));
      base = Scene.add_object(base, Scene.cube(base, (6.0, 0.0, 0.0)));
      do Session.send(sync_channel, { load=base });
      { unchanged };
  Session.make_dynamic(`Central.Modelers`.empty(), on_message);
