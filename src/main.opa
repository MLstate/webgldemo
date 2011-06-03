@private id_work_area = "work_area" ;
@private id_canvas_area = "canvas_area" ;

/*
default_css = css 
#{id_canvas_area} {
   clear:both;
}
;

css = [ default_css ] ;
*/



server_start_static_page() =
  <div>
    <h1 onready={_ -> do Dom.transform([#{id_work_area} +<- <>tralalilalalala</>]); void}>Welcome to this demo</h1>
    <div id=#{id_canvas_area} />                       
    <div id=#{id_work_area} />
  </div> ;

urls =
  parser
  | (.*) ->
    _ = %%WebglPlugin.getContext%% ;
    html("Demo page {Date.to_string(Date.now())}", server_start_static_page())
  end ;


server = simple_server(urls) ;
