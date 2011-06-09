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
  framePickBuffer: Webgl.WebGLFramebuffer
} ;

initPickBuffer(eng) = 
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

drawScene_for_a_viewport(eng, viewport, eye, up, scene) =
  gl = eng.context; shaderProgram = eng.shaderProgram; repcoords = eng.static_buffers.repcoords;
  do Webgl.viewport(gl, viewport.x, viewport.y, viewport.w, viewport.h);
  pMatrix =
    tmp_pMatrix = mat4.create();
    do mat4.perspective(45., float_of_int(eng.canvas.width) / float_of_int(eng.canvas.height), 0.1, 100.0, tmp_pMatrix);
    c = mat4.create() ;
    do mat4.lookAt(vec3.from_public(eye), vec3.from_public((0.0, 0.0, 0.0)), vec3.from_public(up), c);
    do mat4.multiply(tmp_pMatrix, c, tmp_pMatrix);
    tmp_pMatrix;
  mvMatrix = 
    tmp_mvMatrix = mat4.create();
    do mat4.identity(tmp_mvMatrix);
    Stack.push(Stack.create(), tmp_mvMatrix);
  do setMatrixUniforms(gl, shaderProgram, pMatrix, Stack.peek(mvMatrix));
  draw_rep(r, g, b, rep) =
    do Webgl.uniform1i(gl, shaderProgram.useLightingUniform, 0); // 0 = false
    do Webgl.uniform3f(gl, shaderProgram.ambientColorUniform, r, g, b);
    do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), rep.positions);
    do Webgl.vertexAttribPointer(gl, shaderProgram.vertexPositionAttribute, rep.itemSize, Webgl.FLOAT(gl), false, 0, 0);
    do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), rep.normals);
    do Webgl.vertexAttribPointer(gl, shaderProgram.vertexNormalAttribute, rep.itemSize, Webgl.FLOAT(gl), false, 0, 0);
    do Webgl.drawArrays(gl, Webgl.LINES(gl), 0, rep.numItems);
    void ;
  do draw_rep(1.0, 0.0, 0.0, repcoords.x);
  do draw_rep(0.0, 1.0, 0.0, repcoords.y);
  do draw_rep(0.0, 0.0, 1.0, repcoords.z);

  do Webgl.uniform1i(gl, shaderProgram.useLightingUniform, 1); // 1 = true
  do Webgl.uniform3f(gl, shaderProgram.lightingDirectionUniform, 0.85, 0.8, 0.75);
  do List.iter(((pos, object) -> display(eng, pMatrix, mvMatrix, pos, object)), scene) ;
  void
;

drawScene_and_register(eng, get_scene : (->list(vec3))) =
  viewbox = setup_boxes(eng) ;
  rec aux(eng) =
    gl = eng.context;
    scene = List.map((p -> (p, Cube.create(gl))), get_scene());
    do Webgl.clear(gl, Webgl.GLbitfield_OR(Webgl.COLOR_BUFFER_BIT(gl), Webgl.DEPTH_BUFFER_BIT(gl)));
    do drawScene_for_a_viewport(eng, viewbox._YX, (0.0, 0.0, 15.0), (0.0, 1.0, 0.0), scene);
    do drawScene_for_a_viewport(eng, viewbox._YZ, (-15.0, 0.0, 0.0), (0.0, 1.0, 0.0), scene);
    do drawScene_for_a_viewport(eng, viewbox._ZX, (0.0, -15.0, 0.0), (0.0, 0.0, 1.0), scene);
    do drawScene_for_a_viewport(eng, viewbox._3D, (10.0, 5.0, 15.0), (0.0, 1.0, 0.0), scene);
    do RequestAnimationFrame.request((_ -> aux(eng)), #{id_canvas_area});
    void
    ;
  aux(eng) 
;

initGL(canvas_sel, width, height) : void =
  match Webgl.getContext(Dom.of_selection(canvas_sel), "experimental-webgl") with
  | { some=context } ->
    _ = 
      handler(e) = 
        m_pos = // we transform the pos to be relative to the upper leftcorner of the canvas
          c_pos = Dom.get_offset(#{id_canvas_area});
          rel = e.mouse_position_on_page;
          { x_px=max(rel.x_px - c_pos.x_px, 0); y_px=max(rel.y_px - c_pos.y_px, 0) };
        // now with gl the origin will be at the lower left corner
        gl_pos = { x_px=min(max(m_pos.x_px,0), height-1); y_px=min(max(height - 1 - m_pos.y_px, 0), width-1) };
        Log.debug("P", "[(,)-({m_pos.x_px},{m_pos.y_px})] {gl_pos.x_px}, {gl_pos.y_px}");
      Dom.bind(canvas_sel, { mousedown }, handler);
    gl = context;
    eng : engine =
      start = @openrecord({ context=gl; canvas={ selector=canvas_sel; ~width; ~height } });
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
    do drawScene_and_register(eng, (-> [ (0.0, 0.0, 0.0), (3.0, 0.0, 0.0), (6.0, 0.0, 0.0) ]));
    void
  | { none } -> error("no context found")
  end ;
