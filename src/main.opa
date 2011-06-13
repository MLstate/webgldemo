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
  fail_msg = 
    <>It seems that your browser and/or graphics card are incompatible with Webgl.<a href="http://www.khronos.org/webgl/wiki/Getting_a_WebGL_Implementation" >Learn a little more about webgl support</a></> ;
  <div>
    <canvas width={width} height={height} id=#{id_canvas_area} onready={_ -> if Outcome.is_failure(Modeler.init(#{id_canvas_area}, width, height)) then (_ = Dom.put_replace(#{id_canvas_area}, Dom.of_xhtml(fail_msg)); void)}/>
    <div id=#{id_work_area} />
  </div> ;

urls =
  parser
  | "/scene/" scene_url=(.*) ->
    html("3D creation", server_start_static_page())
  | (.*) ->
    html("Welcome", server_welcome_static_page())
  end ;


server = simple_server(urls) ;
