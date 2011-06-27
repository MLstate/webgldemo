import stdlib.widgets.colorpicker
import stdlib.widgets.core

type GuiModeler.t = {
  modeler: Modeler.modeler;
  subjects: { 
    tool: subject(Modeler.tool);
    selection: { this: subject(option(Scene.objects)); color: subject(ColorFloat.color) }
    };
  width: int; height: int
} ;

@client GuiModeler = {{

  Sync = {{
    on_message(state : GuiModeler.t, message) = 
      set_modeler(modeler) = { set={ state with ~modeler } } ;
      set(new_state) = { set={ state with subjects=new_state.subjects; modeler=new_state.modeler } };
      match message : Central.Modelers.sync.message with
      | {load=a_scene} -> 
        modeler = Modeler.load(`Scene.Client`.load(a_scene, state.modeler.client_id), state.modeler.address, state.modeler.client_id, float_of_int(state.height) / float_of_int(state.width));
        subjects = 
          { state.subjects with selection={ 
              this=Observable.change_state(modeler.scene.selection, state.subjects.selection.this); 
              color=
                tmp = Option.switch((o->o.color), ColorFloat.random(), modeler.scene.selection);
                Observable.change_state(tmp , state.subjects.selection.color) } };
        set({ ~subjects; ~modeler })
      | { write_patch; ~patch } -> 
        modeler = Modeler.write_patch(state.modeler, patch);
        set_modeler(modeler)
      end ;
  }}

  empty(scene_url, client_id, width, height) : GuiModeler.t = 
    modeler = Modeler.empty(scene_url, client_id, float_of_int(height) / float_of_int(width));
    subjects = { tool=Observable.make(modeler.tool); selection={ this=Observable.make(modeler.scene.selection); color=Observable.make( Option.switch((o->o.color), ColorFloat.random(), modeler.scene.selection) ) } };
    { ~modeler; ~subjects; ~width; ~height };

  @private on_message(state : GuiModeler.t, message) = 
    _set_modeler(modeler) = { set={ state with ~modeler } } ;
    _set_subjects(subjects) = { set={ state with ~subjects } } ;
    set(new_state) = { set={ state with subjects=new_state.subjects; modeler=new_state.modeler } };
    _set_with_last(new_state) = { set={ state with subjects=new_state.subjects; modeler=new_state.modeler } };
    send_opatch(opatch) =
      m(patch) = { apply_patch; ~patch; address=state.modeler.address }; 
      Option.iter((p -> Session.send(central_modelers, m(p))), opatch);
    reset_subjects(modeler) =
      subjects = { state.subjects with selection={ this=Observable.change_state(modeler.scene.selection, state.subjects.selection.this); 
                                                   color=Observable.change_state( Option.switch((o->o.color), ColorFloat.random(), modeler.scene.selection) , state.subjects.selection.color) } };
      { state with ~subjects; ~modeler };
    match message with
    | {click_on_scene; ~where; ~possible_target} ->
      (modeler, opatch) = Modeler.tool_use(state.modeler, where, possible_target);
      do send_opatch(opatch);
      if Observable.get_state(state.subjects.selection.this) == modeler.scene.selection then
        { set={ state with ~modeler } }
      else
        state = reset_subjects(modeler);
        set(state)
    | {modeler_change_tool=new_tool} ->
      modeler = Modeler.tool_change(state.modeler, new_tool);
      subjects = { state.subjects with tool=Observable.change_state(new_tool, state.subjects.tool) };
      set({ ~subjects; ~modeler })
    | {modeler_change_scene_selection_color; ~new_color} ->
      (modeler, opatch) = Modeler.scene_change_selection_color(state.modeler, new_color);
      do send_opatch(opatch);
      subjects = { state.subjects with selection.color=Observable.change_state(new_color, state.subjects.selection.color) };
      set({ ~subjects; ~modeler})
    | {modeler_apply_possible_move; ~where; ~switch } -> 
      (modeler, opatch) = Modeler.do_possible_move(state.modeler, where, switch);
      do send_opatch(opatch);
      { set={ state with ~modeler } }
    | {modeler_delete_scene_selection} ->
      (modeler, opatch) = Modeler.scene_delete_selection(state.modeler);
      do send_opatch(opatch);
      set(reset_subjects(modeler))
    end ;

  setup_menu(parent_sel, channel, s_tool) : void =
    f(some_tool) = match some_tool with
      | {selection} -> (<span class="button active">Select</span>, <span class="button">Cube</span>)
      | {add_cube} -> (<span class="button">Select</span>, <span class="button active">Cube</span>)
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
      <div class="panel_top"><a id=#{id_a} onclick={s({selection})} ></a> <a id=#{id_b} onclick={s({add_cube})} ></a></div>;
    ignore(Dom.put_at_start(parent_sel, Dom.of_xhtml(menu)));

  setup_selection_view(parent_sel, channel, s_selection) : void =
    id = Random.string(7);
    do
      f(some_selection) = match some_selection with
        | {none} -> <></>
        | {some=_} ->
          id = Random.string(7);
          config =
            style = { WColorpicker.default_config_style with preview=WStyler.make_style(css { height:10px; width:10px; border:1px double black;}) };
            s(a_color) =
              Session.send(channel, {modeler_change_scene_selection_color; new_color=ColorFloat.from_Color_color(a_color)});
            { WColorpicker.default_config with on_select=s; ~style };
          do
            on_sel_color_change =
              then_do(f_new_color) = 
                new_color = ColorFloat.to_Color_color(f_new_color);
                WColorpicker.set_color(id, config, new_color, false);
              { si=(->not(Dom.is_empty(#{id}))); ~then_do; else_autoclean };
            Observable.register(on_sel_color_change, s_selection.color);
          <div class="panel_btm">
            <em>Cube</em>
            <ul>
              <li><label>Color: <div id=#{id} style="display: inline-block" >{ WColorpicker.html(id, config) }</div></label></li>
              <li><a onclick={_ -> Session.send(channel, {modeler_delete_scene_selection})}>Remove me</a></li>
            </ul>
          </div>
        end ;
      on_selection_change =
        then_do(new_selection) = Dom.transform([#{id}<- f(new_selection)]);
        { si=(->not(Dom.is_empty(#{id}))); ~then_do; else_autoclean };
      Observable.register(on_selection_change, s_selection.this);
    sel =
      <div id=#{id}></div>;
    ignore(Dom.put_at_end(parent_sel, Dom.of_xhtml(sel)));

  
  init(scene_url, client_id, parent_sel:dom, width, height) : void =
    id_canvas_canvas = "canvas_canvas" ;
    fail_msg = 
      <>It seems that your browser and/or graphics card are incompatible with Webgl.<a href="http://www.khronos.org/webgl/wiki/Getting_a_WebGL_Implementation" >Learn a little more about webgl support</a></> ;
    and_do(_) =
      (channel, get_scene, get_subjects, get_camera_setting) =
        (channel, sync_channel, get_state) = SessionExt.make_2_side(empty(scene_url, client_id, width, height), on_message, Sync.on_message);
        do Session.send(central_modelers, {register; ~scene_url; ~sync_channel; ~client_id});
        (channel, (-> get_state().modeler.scene), (->get_state().subjects), (->get_state().modeler.views)) ;
      support_gpu_picking = Mutable.make(Option.none);
      mouse_listener =
        epsilon_sensi = 200;
        rec on_message_mouse_listener(state_mouse, msg) =
          match msg with
          | { mousedown; event=_; ~abs_full_pos; ~gl_pos; ~now } ->
            f(gpu_picker_regsiter) =
              sub(possible_target) =
                do Session.send(channel, {click_on_scene; where=gl_pos; ~possible_target});
                Session.send(channel_mouse_listener, { _internal; done_down });
              gpu_picker_regsiter((abs_full_pos, sub)) ;
            do Option.iter(f, support_gpu_picking.get());
            { set={ running_down=List.empty; time_tag=now } }
          | { mouseup; event=_; ~gl_pos; ~switch; now=when_up } ->
            f() =
              msg = {modeler_apply_possible_move; where=gl_pos; ~switch };
              Session.send(channel, msg);
            match state_mouse with
            | { nothing; ~time_tag } ->
              do if (when_up - time_tag) >= epsilon_sensi then f() else void;
              { unchanged }
            | { running_down=l; ~time_tag } ->
              { set={ running_down=List.cons((when_up, f), l); ~time_tag } }
            end
          | { _internal; done_down } -> match state_mouse with
            | { nothing; time_tag=_ } -> { unchanged }
            | { running_down=l; ~time_tag } ->
              g((when_up, f)) =
                if (when_up - time_tag) >= epsilon_sensi then f() else void;
              do List.iter(g, l); { set={ nothing; ~time_tag } }
            end
          end
        and val channel_mouse_listener = Session.make({nothing; time_tag=0}, on_message_mouse_listener);
        (msg -> Session.send(channel_mouse_listener, msg));
      res = initGL(#{id_canvas_canvas}, width, height, get_scene, get_camera_setting, mouse_listener, support_gpu_picking) ;
      if Outcome.is_failure(res) then ignore(Dom.put_replace(parent_sel, Dom.of_xhtml(fail_msg))) 
      else 
        the_subjects = get_subjects();
        do setup_menu(parent_sel, channel, the_subjects.tool);
        setup_selection_view(parent_sel, channel, the_subjects.selection);
    base =
      <div class="canvas_wrap"><canvas width={width} height={height} id=#{id_canvas_canvas} onready={and_do} ></canvas></div>;
    ignore(Dom.put_inside(parent_sel, Dom.of_xhtml(base)));

}}
