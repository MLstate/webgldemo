
server_welcome_static_page() =
  <>
    <h1>Welcome to this demo</h1>
    <p>This basic 3D tool will allow you to collaboratively create a cubic scene.</p>
    <p>It is powered by <a href="http://www.opalang.org">Opa</a>
       and <a href="http://www.khronos.org/webgl/">Webgl</a></p>
    <p><a href="scene/{Random.string(8)}" >&#8658; Create a new 3d scene</a></p>
    <p>&#8658; Collaborate to an existing scene:
      <div id="list_place_holder"
        onready={_ ->
          Session.send(central_modelers,
            { with_address_list = list ->
              xhtml =
                <ul>
                  {List.map(address ->
                    <li><a href="scene/{address}">{address}</a></li>,
                    list)}
                </ul>;
              _ = Dom.put_replace(#list_place_holder, Dom.of_xhtml(xhtml))
              void
            })} />
    </p>
  </> ;
