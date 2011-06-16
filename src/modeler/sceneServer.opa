
type Modeler.Shared.modeler = {
  scene: Scene.scene;
  address: string;
  clients: list(void)
} ;

@server `Modeler.Shared` = {{

  empty(server_id) : Modeler.Shared.modeler = 
    { scene=Scene.empty(server_id); address=Random.string(8); clients=List.empty };

}}


type Central.Modelers.state = stringmap(Modeler.Shared.modeler);
type Central.Modelers.message = { register; scene_url: string; sync_channel: channel(Central.Modelers.sync.message); client_id: int };

type Central.Modelers.sync.message = { load: Scene.scene };

@server `Central.Modelers` = {{
  empty() : Central.Modelers.state = StringMap.empty;

}}

@server central_modelers : channel(Central.Modelers.message) =
  on_message(state, message) = match message with
    | { register; ~scene_url; ~sync_channel; ~client_id } ->
      do Log.info("CM", "register for url '{scene_url}'");
      do Session.send(sync_channel, { load=Scene.a_little_empty((-> 777), client_id) });
      { unchanged };
  Session.make_dynamic(`Central.Modelers`.empty(), on_message);
