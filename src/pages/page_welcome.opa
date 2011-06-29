  my_on_ready(_) =
    with_address_list(list) =
      f(address) =
        xhtml_of_address(address) =
          <li><a href="scene/{address}">{address}</a><span class="arrow">&#8592;</span></li>;
        ignore(Dom.put_at_end(#list_place_holder, Dom.of_xhtml(xhtml_of_address(address))));
      jobs = [
        Dom.Effect.with_duration({slow}, Dom.Effect.fade_out()),
        Dom.Effect.of_simple_fun(d, _ -> ignore(Dom.put_inside(d, Dom.of_xhtml(<ul id="list_place_holder" ></ul>)))),
        Dom.Effect.of_simple_fun(_, _ -> List.iter(f, List.append(list, [ Random.string(8) ]))),
        Dom.Effect.with_duration({slow}, Dom.Effect.fade_in())
        ];
      ignore(Dom.transition(#list_place_holder_loading, Dom.Effect.sequence(jobs)));
    Session.send(central_modelers, { ~with_address_list });

server_welcome_static_page() =
  d = Date.now();
  <div id="welcomeArea" >
    <h3>{ Date.Month.to_short_string(Date.get_month(d)) } { Date.get_day(d) }, { Date.get_year(d) }</h3>
    <h1>Welcome to this demo</h1>
    <hr />
    <p>This basic 3D tool will allow you to collaboratively create a cubic scene.<br />
       It is powered by <a href="http://www.opalang.org">Opa</a>
       and <a href="http://www.khronos.org/webgl/">Webgl</a>.</p>
    <br />
    <br />
    <span>You can collaborate to an existing scene:</span>
    <div id="list_place_holder_loading" onready={my_on_ready} >
      <em><small>loading ...</small></em>
    </div>
  </div> ;

