@private id_work_area = "work_area" ;
@private id_canvas_area = "canvas_area" ;

default_css = css 
#{id_canvas_area} {
   background-color: #D000D0;
}
;

css = [ default_css ] ;

_ = Random.random_init();

/*
ref = Mutable.make(4)
rec val timer42 = Scheduler.make_timer(1000, (->
  do jlog("a")
  if ref.get() == 0 then timer42.stop()
))
do timer42.start()
*/

server_start_static_page() =
  width = 500;
  height = 500;
  <div>
    <canvas width={width} height={height} id=#{id_canvas_area} onready={_ -> Modeler.init(#{id_canvas_area}, width, height)}/>                       
    <div id=#{id_work_area} />
  </div> ;

urls =
  parser
  | "/scene/" scene_url=(.*) ->
    html("3D creation", server_start_static_page())
  | "/Welcome" "/"? ->
    html("Welcome", server_welcome_static_page())
  end ;


server = simple_server(urls) ;
