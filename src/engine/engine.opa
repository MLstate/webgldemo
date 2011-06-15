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

@private type static_buffer = {
  positions: Webgl.WebGLBuffer;
  itemSize: int; numItems: int;
  normals: Webgl.WebGLBuffer
};

@private type engine = {
  context: Webgl.Context.private;
  canvas: { selector:dom; width: int; height: int };
  shaderProgram: my_custom_shaderProgram
  static_buffers: { repcoords: { x:static_buffer; y:static_buffer; z:static_buffer } };
  framePickBuffer: Webgl.WebGLFramebuffer;
  scene: list((vec3, object));
  selector: dom
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
  (vertices, vertexNormals) = match orient with
    | {x} -> ([ 0.0, 0.0, 0.0, 5.0, 0.0, 0.0 ], [ 2.5, 0.0, 0.0,        2.5, -1.0, 0.0 ])
    | {y} -> ([ 0.0, 0.0, 0.0, 0.0, 5.0, 0.0 ], [ 0.0, 2.5, 0.0,        -1.0, 2.5, 0.0 ])
    | {z} -> ([ 0.0, 0.0, 0.0, 0.0, 0.0, 5.0 ], [ 0.0, 0.0, 2.5,        0.0, -1.0, 2.5 ])
    end ;
  vertexPositionBuffer = Webgl.createBuffer(gl);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), vertexPositionBuffer);
  do Webgl.bufferData(gl, Webgl.ARRAY_BUFFER(gl), 
    Webgl.Float32Array.to_ArrayBuffer(Webgl.Float32Array.from_float_list(vertices)), 
    Webgl.STATIC_DRAW(gl));
  vertexNormalBuffer = Webgl.createBuffer(gl);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), vertexNormalBuffer);
  do Webgl.bufferData(gl, Webgl.ARRAY_BUFFER(gl), 
    Webgl.Float32Array.to_ArrayBuffer(Webgl.Float32Array.from_float_list(vertexNormals)), 
    Webgl.STATIC_DRAW(gl));
  { positions=vertexPositionBuffer; itemSize=3; numItems=2; normals=vertexNormalBuffer }
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
  sep_largeur = 2;
  g(x, y, w, h) = { ~x; ~y; ~w; ~h } ;
  compute_left_right(x) = if ((mod(x, 2)) == 0) then
      a = (x / 2) - 1;
      (a, a)
    else
      b = (x / 2);
      (b - 1, b);
  (w_l, w_r) = compute_left_right(eng.canvas.width);
  (h_u, h_d) = compute_left_right(eng.canvas.height);
  { _YX=g(0, h_d+sep_largeur, w_l, h_u); _YZ=g(w_l+sep_largeur, h_d+sep_largeur, w_r, h_u); 
    _ZX=g(0, 0, w_l, h_d); _3D=g(w_l+sep_largeur, 0, w_r, h_d) }
;


drawScene_for_a_viewport(eng, who, viewport, eye, up, scene, mode) =
  gl = eng.context; shaderProgram = eng.shaderProgram; repcoords = eng.static_buffers.repcoords;
  do Webgl.viewport(gl, viewport.x, viewport.y, viewport.w, viewport.h);
  pMatrix =
    tmp_pMatrix = mat4.create();
    match who with
    | {_YX} ->
      do mat4.ortho(-7., 7., -7., 7., -10., 10., tmp_pMatrix);
      tmp_pMatrix
    | {_YZ} ->
      do mat4.ortho(-7., 7., -7., 7., -10., 10., tmp_pMatrix);
      mat4.rotateY(tmp_pMatrix, (90. * Math.PI / 180.), tmp_pMatrix)
    | {_ZX} ->
      do mat4.ortho(-7., 7., -7., 7., -10., 10., tmp_pMatrix);
      mat4.rotateX(tmp_pMatrix, (90. * Math.PI / 180.), tmp_pMatrix)
    | {_3D} ->
      do mat4.perspective(45., float_of_int(eng.canvas.width) / float_of_int(eng.canvas.height), 0.1, 100.0, tmp_pMatrix);
      c = mat4.create() ;
      do mat4.lookAt(vec3.from_public(eye), vec3.from_public((0.0, 0.0, 0.0)), vec3.from_public(up), c);
      do mat4.multiply(tmp_pMatrix, c, tmp_pMatrix);
      tmp_pMatrix
    end ;
  mvMatrix = 
    tmp_mvMatrix = mat4.create();
    do mat4.identity(tmp_mvMatrix);
    Stack.push(Stack.create(), tmp_mvMatrix);
  do setMatrixUniforms(gl, shaderProgram, pMatrix, Stack.peek(mvMatrix));
  draw_rep(r, g, b, rep) =
    do Webgl.uniform3f(gl, shaderProgram.ambientColorUniform, r, g, b);
    do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), rep.positions);
    do Webgl.vertexAttribPointer(gl, shaderProgram.vertexPositionAttribute, rep.itemSize, Webgl.FLOAT(gl), false, 0, 0);
    do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), rep.normals);
    do Webgl.vertexAttribPointer(gl, shaderProgram.vertexNormalAttribute, rep.itemSize, Webgl.FLOAT(gl), false, 0, 0);
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
      List.iter(((pos, object) -> display(eng, pMatrix, mvMatrix, pos, object, false)), scene)
    | {pick} ->
      do Webgl.bindFramebuffer(gl, Webgl.FRAMEBUFFER(gl), Option.some(eng.framePickBuffer));
      do Webgl.clear(gl, Webgl.GLbitfield_OR(Webgl.COLOR_BUFFER_BIT(gl), Webgl.DEPTH_BUFFER_BIT(gl)));
      do Webgl.uniform1i(gl, shaderProgram.useLightingUniform, 0); // 0 = false;
      do List.iter(((pos, object) -> display(eng, pMatrix, mvMatrix, pos, object, true)), scene);
      void
    end ;

  (pMatrix, mvMatrix)
;

drawScene_and_register(org_eng, get_scene : (->Modeler.scene), get_mode) =
  viewbox = setup_boxes(org_eng) ;
  rec aux(eng) =
    gl = eng.context;
    (eng, scene) = 
      f(p) = 
        match List.find((z_in_mem -> z_in_mem.f2.id == p.id), eng.scene) with
        | { some=in_mem } -> { in_mem with f1=p.cube }
        | { none } -> (p.cube, Cube.create(gl, p.id))
        end;
      scene = List.map(f, get_scene());
      ({ eng with ~scene }, scene);
    do match get_mode() with
    | {pick=pos; ~cont} ->
      //do Log.debug("Picking", "...");
      _ = drawScene_for_a_viewport(eng, {_YX}, viewbox._YX, (0.0, 0.0, 15.0), (0.0, 1.0, 0.0), scene, {pick});
      _ = drawScene_for_a_viewport(eng, {_YZ}, viewbox._YZ, (-15.0, 0.0, 0.0), (0.0, 1.0, 0.0), scene, {pick});
      (pMatrix, s) = drawScene_for_a_viewport(eng, {_ZX}, viewbox._ZX, (0.0, -15.0, 0.0), (0.0, 0.0, 1.0), scene, {pick});
      //(pMatrix, s) = drawScene_for_a_viewport(eng, {_3D}, viewbox._3D, (10.0, 5.0, 15.0), (0.0, 1.0, 0.0), scene, {pick});
      x = (float_of_int(pos.x_px - viewbox._ZX.x) / float_of_int(viewbox._ZX.w)) * 2.0 - 1.0;
      y = (float_of_int(pos.y_px - viewbox._ZX.y) / float_of_int(viewbox._ZX.h)) * 2.0 - 1.0;
      mvMatrix = Stack.peek(s) ;
      do mat4.multiply(pMatrix, mvMatrix, mvMatrix);
      do mat4.inverse(mvMatrix, mvMatrix);
      v1 = vec4.from_public((x, y, 1.0, 1.0));
      v2 = vec4.from_public((9.9, 9.9, 9.9, 9.9));
      do mat4.multiplyVec4(mvMatrix, v1, v2);
      v22 = vec4.to_public(v2);
      //v22 = { v22 with f2=0.0 };
      v2 = (v22.f1 / v22.f4, v22.f2 / v22.f4, v22.f3 / v22.f4, v22.f4);
      data = Webgl.Uint8Array.from_int_list(List.init((_->123), 4));
      do Webgl.readPixels(gl, pos.x_px, pos.y_px, 1, 1, Webgl.RGBA(gl), Webgl.UNSIGNED_BYTE(gl), Webgl.Uint8Array.to_ArrayBuffer(data));
      pickedColor = match Webgl.Uint8Array.to_int_list(data) with
        | [r, g, b, _] -> (r, g, b)
        | _ -> error("Picking failure")
        end ;
      do Log.debug("Picking", "Color is: { pickedColor }; v1={ vec4.str(v1) }, \t v2={ v2 }");
      //do jlog("Color is: { pickedColor }; v={ vec3.str(v) }");
      possible_target =
        (r, g, b) = pickedColor;
        f(z) = (z.f2.picking_color == (float_of_int(r) / 255., float_of_int(g) / 255., float_of_int(b) / 255.)) ;
        Option.map((u -> u.f2.id), List.find(f, eng.scene));
      do Webgl.bindFramebuffer(gl, Webgl.FRAMEBUFFER(gl), Option.none);
      cont({ mousedown; x=v2.f1; z=v2.f3; ~possible_target })
    | {normal} ->
      do Webgl.clear(gl, Webgl.GLbitfield_OR(Webgl.COLOR_BUFFER_BIT(gl), Webgl.DEPTH_BUFFER_BIT(gl)));
      _ = drawScene_for_a_viewport(eng, {_YX}, viewbox._YX, (0.0, 0.0, 15.0), (0.0, 1.0, 0.0), scene, {normal});
      _ = drawScene_for_a_viewport(eng, {_YZ}, viewbox._YZ, (-15.0, 0.0, 0.0), (0.0, 1.0, 0.0), scene, {normal});
      _ = drawScene_for_a_viewport(eng, {_ZX}, viewbox._ZX, (0.0, -15.0, 0.0), (0.0, 0.0, 1.0), scene, {normal});
      _ = drawScene_for_a_viewport(eng, {_3D}, viewbox._3D, (10.0, 5.0, 15.0), (0.0, 1.0, 0.0), scene, {normal});
      void
    end ;
    do RequestAnimationFrame.request((_ -> aux(eng)), eng.selector);
    void
    ;
  aux(org_eng) 
;

initGL(canvas_sel, width, height, get_scene, mouse_listener) : outcome =
  match WebGLUtils.setupWebGL_with_custom_failure(Dom.of_selection(canvas_sel)) with
  | { ok=context } ->
    mode = Mutable.make_client({normal});
    is_picking(m) = match m with | { pick=_; cont=_ } -> true | _ -> false end;
    _ = 
      handler(e) = 
        m_pos = // we transform the pos to be relative to the upper leftcorner of the canvas
          c_pos = Dom.get_offset(canvas_sel);
          rel = e.mouse_position_on_page;
          { x_px=max(rel.x_px - c_pos.x_px, 0); y_px=max(rel.y_px - c_pos.y_px, 0) };
        // now with gl the origin will be at the lower left corner
        gl_pos = { x_px=min(max(m_pos.x_px,0), height-1); y_px=min(max(height - 1 - m_pos.y_px, 0), width-1) };
        cont(e) =
          do mode.set({normal});
          mouse_listener(e);
        do if not(is_picking(mode.get())) then mode.set({pick=gl_pos; ~cont});
        Log.debug("P", "[(,)-({m_pos.x_px},{m_pos.y_px})] {gl_pos.x_px}, {gl_pos.y_px}");
      Dom.bind(canvas_sel, { mousedown }, handler);
    gl = context;
    eng : engine =
      start = @openrecord({ context=gl; canvas={ selector=canvas_sel; ~width; ~height }; scene=List.empty; selector=canvas_sel });
      start = { start with shaderProgram=initShaders(gl) };
      start = { start with framePickBuffer=initPickBuffer(start) } ;
      { start with static_buffers.repcoords=
        { x=initLineXBuffers(gl, {x}); y=initLineXBuffers(gl, {y}); z=initLineXBuffers(gl, {z}) } };
    //Clear screen and make everything light gray
    do Webgl.clearColor(gl, 0.9, 0.9, 0.9, 1.0);
    //we should do depth testing so that things drawn behind other
    //things should be hidden by the things in front of them).
    do Webgl.clearDepth(gl, 1.0);
    do Webgl.enable(gl, Webgl.DEPTH_TEST(gl));
    do Webgl.depthFunc(gl, Webgl.LEQUAL(gl));
    do drawScene_and_register(eng, get_scene, mode.get);
    { success }
  | { ~ko } -> { failure=ko }
  end ;
