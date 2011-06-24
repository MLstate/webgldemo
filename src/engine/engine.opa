@private type my_custom_shaderProgram = { 
  program: Webgl.WebGLProgram;
  vertexPositionAttribute: Webgl.GLint;
  vertexNormalAttribute: Webgl.GLint;
  pMatrixUniform: Webgl.WebGLUniformLocation;
  mvMatrixUniform: Webgl.WebGLUniformLocation;
  nMatrixUniform: Webgl.WebGLUniformLocation;
  ambientColorUniform: Webgl.WebGLUniformLocation;
  lightingDirectionUniform: Webgl.WebGLUniformLocation;
  useLightingUniform: Webgl.WebGLUniformLocation 
};

@private type engine.scene = list(object);

@private type engine = {
  context: Webgl.Context.private;
  canvas: { selector:dom; width: int; height: int };
  shaderProgram: my_custom_shaderProgram
  static_buffers: { repcoords: { x: object.simple; y: object.simple; z: object.simple } };
  framePickBuffer: Webgl.WebGLFramebuffer;
  scene: engine.scene;
  selector: dom;
} ;

@client initPickBuffer(eng) = 
  gl = eng.context;
  framePickBuffer = Webgl.createFramebuffer(gl);
  renderPickBuffer = Webgl.createRenderbuffer(gl);
  pickTexture = Webgl.createTexture(gl);
  do Webgl.bindTexture(gl, Webgl.TEXTURE_2D(gl), Option.some(pickTexture));
  tex = Webgl.Uint8Array.from_int_list([0, 0, 0]);
  do Webgl.texImage2D(gl, Webgl.TEXTURE_2D(gl), 0, Webgl.RGB(gl), eng.canvas.width, eng.canvas.height, 0, Webgl.RGB(gl), Webgl.UNSIGNED_BYTE(gl), Webgl.Uint8Array.to_ArrayBuffer(tex));
  do Webgl.bindFramebuffer(gl, Webgl.FRAMEBUFFER(gl), Option.some(framePickBuffer));
  do Webgl.bindRenderbuffer(gl, Webgl.RENDERBUFFER(gl), Option.some(renderPickBuffer));
  do Webgl.renderbufferStorage(gl, Webgl.RENDERBUFFER(gl), Webgl.DEPTH_COMPONENT16(gl), eng.canvas.width, eng.canvas.height);
  do Webgl.bindRenderbuffer(gl, Webgl.RENDERBUFFER(gl), Option.none);

  do Webgl.framebufferTexture2D(gl, Webgl.FRAMEBUFFER(gl), Webgl.COLOR_ATTACHMENT0(gl), Webgl.TEXTURE_2D(gl), pickTexture, 0);
  do Webgl.framebufferRenderbuffer(gl, Webgl.FRAMEBUFFER(gl), Webgl.DEPTH_ATTACHMENT(gl), Webgl.RENDERBUFFER(gl), renderPickBuffer);  
  do Webgl.bindFramebuffer(gl, Webgl.FRAMEBUFFER(gl), Option.none);
  do Webgl.bindTexture(gl, Webgl.TEXTURE_2D(gl), Option.none);
  framePickBuffer
;

initShaders(gl) = 
  f(e, str) = 
    shader = Webgl.createShader(gl, e);
    do Webgl.shaderSource(gl, shader, str);
    do Webgl.compileShader(gl, shader);
    shader;
  fragmentShader = f(Webgl.FRAGMENT_SHADER(gl), CustomShaders.shader_fs);
  vertexShader = f(Webgl.VERTEX_SHADER(gl), CustomShaders.shader_vs);
  // TODO getShaderParameter
  shaderProgram = Webgl.createProgram(gl);
  do Webgl.attachShader(gl, shaderProgram, vertexShader);
  do Webgl.attachShader(gl, shaderProgram, fragmentShader);
  do Webgl.linkProgram(gl, shaderProgram);
  // TODO : getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
  do Webgl.useProgram(gl, shaderProgram);
  shaderProgram = 
    vertexPositionAttribute = Webgl.getAttribLocation(gl, shaderProgram, "aVertexPosition");
    vertexNormalAttribute = Webgl.getAttribLocation(gl, shaderProgram, "aVertexNormal");
    do Webgl.enableVertexAttribArray(gl, vertexPositionAttribute);
    do Webgl.enableVertexAttribArray(gl, vertexNormalAttribute);
    { program = shaderProgram;
      ~vertexPositionAttribute;
      ~vertexNormalAttribute;
      pMatrixUniform = Webgl.getUniformLocation(gl, shaderProgram, "uPMatrix");
      mvMatrixUniform = Webgl.getUniformLocation(gl, shaderProgram, "uMVMatrix");
      nMatrixUniform = Webgl.getUniformLocation(gl, shaderProgram, "uNMatrix");
      ambientColorUniform = Webgl.getUniformLocation(gl, shaderProgram, "uAmbientColor");
      lightingDirectionUniform = Webgl.getUniformLocation(gl, shaderProgram, "uLightingDirection");
      useLightingUniform = Webgl.getUniformLocation(gl, shaderProgram, "uUseLighting");
    };
  shaderProgram
;

initLineXBuffers(gl, orient) =
  vertices = match orient with
    | {x} -> [ 0.0, 0.0, 0.0, 5.0, 0.0, 0.0 ]
    | {y} -> [ 0.0, 0.0, 0.0, 0.0, 5.0, 0.0 ]
    | {z} -> [ 0.0, 0.0, 0.0, 0.0, 0.0, 5.0 ]
    end ;
  vertexPositionBuffer = Webgl.createBuffer(gl);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), vertexPositionBuffer);
  do Webgl.bufferData(gl, Webgl.ARRAY_BUFFER(gl), 
    Webgl.Float32Array.to_ArrayBuffer(Webgl.Float32Array.from_float_list(vertices)), 
    Webgl.STATIC_DRAW(gl));
  { positions=vertexPositionBuffer; itemSize=3; numItems=2; normals=Option.none; beginMode=Webgl.LINES(gl) }
;

setMatrixUniforms(gl, shaderProgram, pMatrix, mvMatrix) =
  a = 
    b = mat4.to_list(pMatrix);
    c = Webgl.Float32Array.from_float_list(b);
    c;
  e =
    f = mat4.to_list(mvMatrix);
    g = Webgl.Float32Array.from_float_list(f);
    g;
  do Webgl.uniformMatrix4fv(gl, shaderProgram.pMatrixUniform, false, a);
  do Webgl.uniformMatrix4fv(gl, shaderProgram.mvMatrixUniform, false, e);
  normalMatrix = mat3.create();
  do mat4.toInverseMat3(mvMatrix, normalMatrix);
  do mat3.transpose(normalMatrix, normalMatrix);
  do Webgl.uniformMatrix3fv(gl, shaderProgram.nMatrixUniform, false, Webgl.Float32Array.from_float_list(mat3.to_list(normalMatrix)));
  void
;

setup_boxes(eng) =
  g(x:int, y:int, w:int, h:int) =
    inbox(pos) = (pos.x_px >= x) && (pos.y_px >= y) && (pos.x_px < (w + x)) && (pos.y_px < (h + y));
    { ~x; ~y; ~w; ~h; ~inbox } ;
  compute_left_right(x) = if ((mod(x, 2)) == 0) then
      a = (x / 2);
      ((a, a), 0)
    else
      b = (x / 2);
      ((b, b+1), 0);
  ((w_l, w_r), e_w) = compute_left_right(eng.canvas.width);
  ((h_u, h_d), e_h) = compute_left_right(eng.canvas.height);
  { _YX=g(0, h_d+e_h, w_l, h_u); _YZ=g(w_l+e_w, h_d+e_h, w_r, h_u);
    _ZX=g(0, 0, w_l, h_d);       _3D=g(w_l+e_w, 0, w_r, h_d) }
;

which_box(b, pos) =
  if b._YX.inbox(pos) then {_YX}
  else if b._YZ.inbox(pos) then {_YZ}
  else if b._ZX.inbox(pos) then {_ZX}
  else if b._3D.inbox(pos) then {_3D}
  else {out}
;

fetch_box(b, who) = match who with
  | {_YX} -> b._YX
  | {_YZ} -> b._YZ
  | {_ZX} -> b._ZX
  | {_3D} -> b._3D
  end ;

rel_pos_in_box(this_viewbox, pos) =
  x = (float_of_int(pos.x_px - this_viewbox.x) / float_of_int(this_viewbox.w)) * 2.0 - 1.0;
  y = (float_of_int(pos.y_px - this_viewbox.y) / float_of_int(this_viewbox.h)) * 2.0 - 1.0;
  (x, y);

drawScene_for_a_viewport(eng, who, viewport, camera_setting : mat4, scene, mode) =
  gl = eng.context; shaderProgram = eng.shaderProgram; repcoords = eng.static_buffers.repcoords;
  do Webgl.viewport(gl, viewport.x, viewport.y, viewport.w, viewport.h);
  pMatrix = camera_setting;
  mvMatrix = 
    tmp_mvMatrix = mat4.create();
    do mat4.identity(tmp_mvMatrix);
    Stack.push(Stack.create(), tmp_mvMatrix);
  do setMatrixUniforms(gl, shaderProgram, pMatrix, Stack.peek(mvMatrix));
  draw_rep(r, g, b, rep) =
    do Webgl.uniform3f(gl, shaderProgram.ambientColorUniform, r, g, b);
    do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), rep.positions);
    do Webgl.vertexAttribPointer(gl, shaderProgram.vertexPositionAttribute, rep.itemSize, Webgl.FLOAT(gl), false, 0, 0);
    do Webgl.drawArrays(gl, Webgl.LINES(gl), 0, rep.numItems);
    void ;

  _ = 
    match mode with
    | {normal} ->
      do Webgl.uniform1i(gl, shaderProgram.useLightingUniform, 0); // 0 = false
      do draw_rep(1.0, 0.0, 0.0, repcoords.x);
      do draw_rep(0.0, 1.0, 0.0, repcoords.y);
      do draw_rep(0.0, 0.0, 1.0, repcoords.z);
      do match who with 
        | {_3D} -> 
          do Webgl.uniform1i(gl, shaderProgram.useLightingUniform, 1); // 1 = true
          Webgl.uniform3f(gl, shaderProgram.lightingDirectionUniform, 0.85, 0.8, 0.75)
        | _ -> void end;
      List.iter((object -> display_pickable(eng, pMatrix, mvMatrix, object, false)), scene)
    | {pick} ->
      do Webgl.bindFramebuffer(gl, Webgl.FRAMEBUFFER(gl), Option.some(eng.framePickBuffer));
      do Webgl.clear(gl, Webgl.GLbitfield_OR(Webgl.COLOR_BUFFER_BIT(gl), Webgl.DEPTH_BUFFER_BIT(gl)));
      do Webgl.uniform1i(gl, shaderProgram.useLightingUniform, 0); // 0 = false;
      do List.iter((object -> display_pickable(eng, pMatrix, mvMatrix, object, true)), scene);
      void
    end ;

  (pMatrix, mvMatrix)
;

@private drawScene_and_register(org_eng, viewbox, get_scene : (->Scene.Client.scene), get_camera_setting : (->Modeler.views)) =
  to_be_pick = Mutable.make(List.empty);
  rec aux(eng:engine) = (
    gl = eng.context;
    (eng, scene) =
      f(is_selected, p) =
        match List.find((z_in_mem -> z_in_mem.id == p.id), eng.scene) with
        | { some=in_mem } -> { in_mem with position=p.cube; ~is_selected; color=p.color }
        | { none } -> Cube.create(gl, p, is_selected)
        end;
      scene : engine.scene =
        tmp = get_scene();
        others_scene = List.map(f(false, _), tmp.others.objs);
        selection_scene = Option.switch((the -> [ f(true, the) ]), List.empty, tmp.selection);
        List.append(selection_scene, others_scene);
      ({ eng with ~scene }, scene);
    views = get_camera_setting();

    tmp_f(pos) = (
      match which_box(viewbox, pos) with
      | {out} -> Option.none
      | {_YX} as who | {_YZ} as who | {_ZX} as who | {_3D} as who ->
        this_viewbox = fetch_box(viewbox, who);
        some_settings = fetch_box(views, who);
        mvMatrix = mat4.copy(some_settings.m) ;
        _ = drawScene_for_a_viewport(eng, who, this_viewbox, mvMatrix, scene, {pick});
        possible_target =
          pickedColor =
            data = Webgl.Uint8Array.from_int_list(List.init((_->123), 4));
            do Webgl.readPixels(gl, pos.x_px, pos.y_px, 1, 1, Webgl.RGBA(gl), Webgl.UNSIGNED_BYTE(gl), Webgl.Uint8Array.to_ArrayBuffer(data));
            match Webgl.Uint8Array.to_int_list(data) with
            | [r, g, b, _] -> (r, g, b)
            | _ -> error("Picking failure")
            end ;
          do Log.debug("Picking", "Color is: { pickedColor }");
          f =
            (r, g, b) = pickedColor;
            (z -> (z.picking_color == (float_of_int(r) / 255., float_of_int(g) / 255., float_of_int(b) / 255.))) ;
          Option.map((u -> u.id), List.find(f, eng.scene));
        possible_target
      end);
    tmp = to_be_pick.get();
    do to_be_pick.set(List.empty);
    do List.iter(((pos, f) -> f(tmp_f(pos))), tmp);
    do Webgl.bindFramebuffer(gl, Webgl.FRAMEBUFFER(gl), Option.none);

    eng =
      do Webgl.clear(gl, Webgl.GLbitfield_OR(Webgl.COLOR_BUFFER_BIT(gl), Webgl.DEPTH_BUFFER_BIT(gl)));
      _ = drawScene_for_a_viewport(eng, {_YX}, viewbox._YX, views._YX.m, scene, {normal});
      _ = drawScene_for_a_viewport(eng, {_YZ}, viewbox._YZ, views._YZ.m, scene, {normal});
      _ = drawScene_for_a_viewport(eng, {_ZX}, viewbox._ZX, views._ZX.m, scene, {normal});
      _ = drawScene_for_a_viewport(eng, {_3D}, viewbox._3D, views._3D.m, scene, {normal});
      eng;

    do RequestAnimationFrame.request((_ -> aux(eng)), eng.selector);
    void );

  do aux(org_eng);
  (a -> to_be_pick.set(List.cons(a, to_be_pick.get())))
;

initGL(canvas_sel, width, height, get_scene, get_camera_setting, mouse_listener, support_gpu_picking) : outcome =
  match WebGLUtils.setupWebGL_with_custom_failure(Dom.of_selection(canvas_sel)) with
  | { ok=context } ->
    gl = context;
    eng : engine =
      start = @openrecord({ context=gl; canvas={ selector=canvas_sel; ~width; ~height }; scene=List.empty; selector=canvas_sel });
      start = { start with shaderProgram=initShaders(gl) };
      start = { start with framePickBuffer=initPickBuffer(start) } ;
      { start with static_buffers.repcoords=
        { x=initLineXBuffers(gl, {x}); y=initLineXBuffers(gl, {y}); z=initLineXBuffers(gl, {z}) } };
    viewbox = setup_boxes(eng) ;
    {} =
      compute_abs_full_pos(rel_mouse_position_on_page) =
        m_pos = // we transform the pos to be relative to the upper leftcorner of the canvas
          c_pos = Dom.get_offset(canvas_sel);
          rel = rel_mouse_position_on_page;
          { x_px=max(rel.x_px - c_pos.x_px, 0); y_px=max(rel.y_px - c_pos.y_px, 0) };
        // now with gl the origin will be at the lower left corner
        abs_full_pos = { x_px=min(max(m_pos.x_px,0), width-1); y_px=min(max(height - 1 - m_pos.y_px, 0), height-1) };
        do Log.debug("P", "[rel_mouse_position_on_page=({m_pos})] abs_full_pos=({abs_full_pos})");
        abs_full_pos;
      compute_rel_quarter_pos(abs_full_pos) =
        match which_box(viewbox, abs_full_pos) with
        | {out} -> ((0., 0., 0.), {f1}, {out})
        | {_YX} as who | {_YZ} as who | {_ZX} as who | {_3D} as who ->
          this_viewbox = fetch_box(viewbox, who);
          some_settings = fetch_box(get_camera_setting(), who);
          mvMatrix = mat4.copy(some_settings.m);
          do mat4.inverse(mvMatrix, mvMatrix);
          (x, y) = rel_pos_in_box(this_viewbox, abs_full_pos);
          vstart = vec4.from_public((x, y, 1.0, 1.0));
          vtmp = vec4.from_public((9.9, 9.9, 9.9, 9.9));
          do mat4.multiplyVec4(mvMatrix, vstart, vtmp);
          vpreres = vec4.to_public(vtmp);
          vres = (vpreres.f1 / vpreres.f4, vpreres.f2 / vpreres.f4, vpreres.f3 / vpreres.f4);
          do Log.debug("Converting coord", "vstart={ vec4.str(vstart) }, \t vres={ vres }");
          (vres, some_settings.clear_near_far, who);
      handler_mousedown(event) =
        abs_full_pos=compute_abs_full_pos(event.mouse_position_on_page);
        (gl_pos, clear_near_far, _) = compute_rel_quarter_pos(abs_full_pos);
        mouse_listener({ mousedown; ~event; ~abs_full_pos; gl_pos=vec3.apply(gl_pos, clear_near_far, (_-> 0.0)) })
      do ignore(Dom.bind(canvas_sel, { mousedown }, handler_mousedown));
      handler_mouseup(event) =
        abs_full_pos=compute_abs_full_pos(event.mouse_position_on_page);
        (gl_pos, clear_near_far, who) = compute_rel_quarter_pos(abs_full_pos);
        match who with
        | {_3D} -> void
        | _ -> mouse_listener({ mouseup; ~event; gl_pos=vec3.apply(gl_pos, clear_near_far, (_-> 0.0)); switch=clear_near_far })
      do ignore(Dom.bind(canvas_sel, { mouseup }, handler_mouseup));
      void;
    //Clear screen and make everything light gray // disabled to show png grid
    //do Webgl.clearColor(gl, 0.875, 0.875, 0.875, 1.0);
    //we should do depth testing so that things drawn behind other
    //things should be hidden by the things in front of them).
    do Webgl.clearDepth(gl, 1.0);
    do Webgl.enable(gl, Webgl.DEPTH_TEST(gl));
    do Webgl.depthFunc(gl, Webgl.LEQUAL(gl));
    do
      gpu_picker_register = drawScene_and_register(eng, viewbox, get_scene, get_camera_setting);
      do ignore(support_gpu_picking.set(Option.some(gpu_picker_register)));
      void
    { success }
  | { ~ko } -> { failure=ko }
  end ;
