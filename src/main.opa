@private id_work_area = "work_area" ;
@private id_canvas_area = "canvas_area" ;

default_css = css 
#{id_canvas_area} {
   background-color: #D000D0;
}
;

css = [ default_css ] ;

server_start_static_page() =
  width = 500;
  height = 500;
  <div>
    <h1>Welcome to this demo</h1>
    <canvas width={width} height={height} id=#{id_canvas_area} onready={_ -> initGL(#{id_canvas_area})}/>                       
    <div id=#{id_work_area} />
  </div> ;

urls =
  parser
  | (.*) ->
    html("Demo page {Date.to_string(Date.now())}", server_start_static_page())
  end ;


server = simple_server(urls) ;
