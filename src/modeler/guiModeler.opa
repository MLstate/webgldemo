type GuiModeler.t = {
  modeler: Modeler.modeler;
  subjects: { 
    tool: subject(Modeler.tool);
    selection: { this: subject(option(Scene.objects)); color: subject(ColorFloat.color) }
    }
} ;

@client GuiModeler = {{

  empty(scene_url) : GuiModeler.t = 
    modeler = Modeler.empty(scene_url);
    subjects = { tool=Observable.make(modeler.tool); selection={ this=Observable.make(modeler.scene.selection); color=Observable.make( Option.switch((o->o.color), ColorFloat.random(), modeler.scene.selection) ) } };
    { ~modeler; ~subjects };

  @private on_message(state : GuiModeler.t, message) = 
    set_modeler(modeler) = { set={ state with ~modeler } } ;
    set_subjects(subjects) = { set={ state with ~subjects } } ;
    set(state) = { set=state };
    match message with
    | {click_on_scene; ~where; ~possible_target} -> 
      modeler = Modeler.tool_use(state.modeler, where, possible_target);
      if Observable.get_state(state.subjects.selection.this) == modeler.scene.selection then
        set_modeler(modeler)
      else
        subjects = { state.subjects with selection={ this=Observable.change_state(modeler.scene.selection, state.subjects.selection.this); 
                                                     color=Observable.change_state( Option.switch((o->o.color), ColorFloat.random(), modeler.scene.selection) , state.subjects.selection.color) } };
        set({ ~subjects; ~modeler })
    | {modeler_change_tool=new_tool} ->
      modeler = Modeler.tool_change(state.modeler, new_tool);
      subjects = { state.subjects with tool=Observable.change_state(new_tool, state.subjects.tool) };
      set({ ~subjects; ~modeler })
    | {modeler_change_scene_selection_color; ~new_color} ->
      modeler = Modeler.scene_change_selection_color(state.modeler, new_color);
      subjects = { state.subjects with selection.color=Observable.change_state(new_color, state.subjects.selection.color) };
      set({ ~subjects; ~modeler})
    end ;

  setup_menu(parent_sel, channel, s_tool) : void =
    f(some_tool) = match some_tool with
      | {selection} -> (<>*Sel*</>, <>Cube</>)
      | {add_cube} -> (<>Sel</>, <>*Cube*</>)
      end ;
    (id_a, id_b) = (Random.string(7), Random.string(7));
    on_tool_change = 
      then_do(new_tool) = 
        (text_a, text_b) = f(new_tool);
        Dom.transform([#{id_a}<- text_a, #{id_b}<- text_b]);
      { si=(-> not(Dom.is_empty(#{id_a})) && not(Dom.is_empty(#{id_b}))); ~then_do; else_autoclean };
    do Observable.register(on_tool_change, s_tool);
    menu =
      s(x) = (_ -> Session.send(channel, {modeler_change_tool=x}));
      <p><a id=#{id_a} onclick={s({selection})} >.</a> | <a id=#{id_b} onclick={s({add_cube})} >.</a></p>;
    ignore(Dom.put_at_start(parent_sel, Dom.of_xhtml(menu)));

  setup_selection_view(parent_sel, channel, s_selection) : void =
    id = Random.string(7);
    do
      f(some_selection) = match some_selection with
        | {none} -> <></>
        | {~some} ->
          id = Random.string(7);
          do
            c(a_color) = Color.color_to_string(a_color);
            on_sel_color_change =
              then_do(new_color) = 
                new_color = ColorFloat.to_Color_color(new_color);
                do Dom.transform([#{id}<- c(new_color)]); 
                Dom.set_style(#{id}, [ {background=Css_build.background_color(new_color)} ]);
              { si=(->not(Dom.is_empty(#{id}))); ~then_do; else_autoclean };
            Observable.register(on_sel_color_change, s_selection.color);
          s(new_color) = (_ -> Session.send(channel, {modeler_change_scene_selection_color; ~new_color}));
          <label>Color: <span id=#{id} width="5px" height="5px" onclick={s(ColorFloat.random())} >*</span></label>
        end ;
      on_selection_change =
        then_do(new_selection) = Dom.transform([#{id}<- f(new_selection)]);
        { si=(->not(Dom.is_empty(#{id}))); ~then_do; else_autoclean };
      Observable.register(on_selection_change, s_selection.this);
    sel =
      <div id=#{id} ></div>;
    ignore(Dom.put_at_end(parent_sel, Dom.of_xhtml(sel)));

  
  init(scene_url, parent_sel:dom, width, height) : void =
    id_canvas_canvas = "canvas_canvas" ;
    fail_msg = 
      <>It seems that your browser and/or graphics card are incompatible with Webgl.<a href="http://www.khronos.org/webgl/wiki/Getting_a_WebGL_Implementation" >Learn a little more about webgl support</a></> ;
    and_do(_) =
      (channel, get_scene, get_subjects) =
        (channel, get_state) = SessionExt.make_with_getter(empty(scene_url), on_message);
        (channel, (-> get_state().modeler.scene), (->get_state().subjects)) ;
      mouse_listener(e) = match e with
        | { mousedown; ~pos; ~possible_target } -> Session.send(channel, {click_on_scene; where={x=pos.f1; y=pos.f2; z=pos.f3}; ~possible_target})
        end ;
      res = initGL(#{id_canvas_canvas}, width, height, get_scene, mouse_listener) ;
      if Outcome.is_failure(res) then ignore(Dom.put_replace(parent_sel, Dom.of_xhtml(fail_msg))) 
      else 
        the_subjects = get_subjects();
        do setup_menu(parent_sel, channel, the_subjects.tool);
        setup_selection_view(parent_sel, channel, the_subjects.selection);
    base =
      <canvas width={width} height={height} id=#{id_canvas_canvas} onready={and_do} ></canvas>;
    ignore(Dom.put_inside(parent_sel, Dom.of_xhtml(base)));

}}