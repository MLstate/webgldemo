@private id_work_area = "work_area" ;
@private id_gui_area = "gui_area" ;

_ = Random.random_init();

/*
ref = Mutable.make(4)
rec val timer42 = Scheduler.make_timer(1000, (->
  do jlog("a")
  if ref.get() == 0 then timer42.stop()
))
do timer42.start()
*/

server_modeler_static_page(scene_url) =
  width = 500;
  height = 500;
  <div class="container">
    <div id=#{id_gui_area} onready={_ -> GuiModeler.init(scene_url, SHF(), #{id_gui_area}, width, height)}/>
    <div id=#{id_work_area} />
  </div> ;

resources = Rule.of_map(@static_include_directory("./src/css"))

urls =
  parser
  | "/" r=resources -> r
  | "/scene/" scene_url=(.*) ->
    Resource.styled_page("3D creation", ["/src/css/style.css"],server_modeler_static_page(Text.to_string(scene_url)))
  | (.*) ->
    html("Welcome", server_welcome_static_page())
  end ;


server = simple_server(urls) ;
