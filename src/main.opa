@private id_work_area = "work_area" ;
@private id_gui_area = "gui_area" ;

_ = Random.random_init();

server_modeler_static_page(scene_url) =
  width = 800;
  height = 600;
  <div class="container">
    <div id=#{id_gui_area} onready={_ -> GuiModeler.init(scene_url, SHF(), #{id_gui_area}, width, height)}/>
    <div id=#{id_work_area} />
  </div> ;

resources_css = Rule.of_map(@static_include_directory("./css"))
resources_img = Rule.of_map(@static_include_directory("./img"))

urls =
  parser
  | "/" r=resources_css -> r
  | "/" r=resources_img -> r
  | "/scene/" scene_url=(.*) ->
    Resource.styled_page("3D creation", ["/css/style.css"], server_modeler_static_page(Text.to_string(scene_url)))
  | (.*) ->
    Resource.styled_page("Welcome", ["/css/style.css"], server_welcome_static_page())
  end ;


server = simple_server(urls) ;
