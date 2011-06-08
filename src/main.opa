@private id_work_area = "work_area" ;
@private id_canvas_area = "canvas_area" ;

default_css = css 
#{id_canvas_area} {
   background-color: #D000D0;
}
;

css = [ default_css ] ;

width = 500;
height = 500;

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


initBuffers(gl) =
  //global variable to hold the square buffer
  //We create a buffer for the square's vertex positions.
  squareVertexPositionBuffer = Webgl.createBuffer(gl);
  //tells WebGL that any following operations that act on buffers should use the one we specify
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), squareVertexPositionBuffer);
  //define our vertex positions as a list
  vertices = [
      // Front face
      -1.0, -1.0,  1.0,
       1.0, -1.0,  1.0,
       1.0,  1.0,  1.0,
      -1.0,  1.0,  1.0,

      // Back face
      -1.0, -1.0, -1.0,
      -1.0,  1.0, -1.0,
       1.0,  1.0, -1.0,
       1.0, -1.0, -1.0,

      // Top face
      -1.0,  1.0, -1.0,
      -1.0,  1.0,  1.0,
       1.0,  1.0,  1.0,
       1.0,  1.0, -1.0,

      // Bottom face
      -1.0, -1.0, -1.0,
       1.0, -1.0, -1.0,
       1.0, -1.0,  1.0,
      -1.0, -1.0,  1.0,

      // Right face
       1.0, -1.0, -1.0,
       1.0,  1.0, -1.0,
       1.0,  1.0,  1.0,
       1.0, -1.0,  1.0,

      // Left face
      -1.0, -1.0, -1.0,
      -1.0, -1.0,  1.0,
      -1.0,  1.0,  1.0,
      -1.0,  1.0, -1.0,
    ];
  vertexNormals = [
    // Front
     0.0,  0.0,  1.0,
     0.0,  0.0,  1.0,
     0.0,  0.0,  1.0,
     0.0,  0.0,  1.0,
     
    // Back
     0.0,  0.0, -1.0,
     0.0,  0.0, -1.0,
     0.0,  0.0, -1.0,
     0.0,  0.0, -1.0,
     
    // Top
     0.0,  1.0,  0.0,
     0.0,  1.0,  0.0,
     0.0,  1.0,  0.0,
     0.0,  1.0,  0.0,
     
    // Bottom
     0.0, -1.0,  0.0,
     0.0, -1.0,  0.0,
     0.0, -1.0,  0.0,
     0.0, -1.0,  0.0,
     
    // Right
     1.0,  0.0,  0.0,
     1.0,  0.0,  0.0,
     1.0,  0.0,  0.0,
     1.0,  0.0,  0.0,
     
    // Left
    -1.0,  0.0,  0.0,
    -1.0,  0.0,  0.0,
    -1.0,  0.0,  0.0,
    -1.0,  0.0,  0.0
  ];
  cubeVertexIndices = [
            0, 1, 2,      0, 2, 3,    // Front face
            4, 5, 6,      4, 6, 7,    // Back face
            8, 9, 10,     8, 10, 11,  // Top face
            12, 13, 14,   12, 14, 15, // Bottom face
            16, 17, 18,   16, 18, 19, // Right face
            20, 21, 22,   20, 22, 23  // Left face
        ];
  //Now, we create a Float32Array object based on our list, 
  //and tell WebGL to use it to fill the current buffer
  do Webgl.bufferData(gl, Webgl.ARRAY_BUFFER(gl), Webgl.Float32Array.to_ArrayBuffer(Webgl.Float32Array.from_float_list(vertices)), Webgl.STATIC_DRAW(gl));
  //this 9-element buffer actually represents three separate vertex 
  //positions (numItems), each of which is made up of three numbers (itemSize).
  //do Webgl.set_itemSize(squareVertexPositionBuffer, 3);
  //do Webgl.set_numItems(squareVertexPositionBuffer, 4);
  squareVertexNormalBuffer = Webgl.createBuffer(gl);
  //tells WebGL that any following operations that act on buffers should use the one we specify
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), squareVertexNormalBuffer);
  do Webgl.bufferData(gl, Webgl.ARRAY_BUFFER(gl), Webgl.Float32Array.to_ArrayBuffer(Webgl.Float32Array.from_float_list(vertexNormals)), Webgl.STATIC_DRAW(gl));
  cubeVertexIndexBuffer = Webgl.createBuffer(gl);
  do Webgl.bindBuffer(gl, Webgl.ELEMENT_ARRAY_BUFFER(gl), cubeVertexIndexBuffer);
  do Webgl.bufferData(gl, Webgl.ELEMENT_ARRAY_BUFFER(gl), Webgl.Uint16Array.to_ArrayBuffer(Webgl.Uint16Array.from_int_list(cubeVertexIndices)), Webgl.STATIC_DRAW(gl));
  { positions=squareVertexPositionBuffer; itemSize=3; numItems=24; normals=squareVertexNormalBuffer; indexs=cubeVertexIndexBuffer }
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

setup_boxes() = 
  sep_largeur = 2;
  g(x, y, w, h) = { ~x; ~y; ~w; ~h } ;
  compute_left_right(x) = if ((mod(x, 2)) == 0) then
      a = (x / 2) - 1;
      (a, a)
    else
      b = (x / 2);
      (b - 1, b);
  (w_l, w_r) = compute_left_right(width);
  (h_u, h_d) = compute_left_right(height);
  { _YX=g(0, h_d+sep_largeur, w_l, h_u); _YZ=g(w_l+sep_largeur, h_d+sep_largeur, w_r, h_u); 
    _ZX=g(0, 0, w_l, h_d); _3D=g(w_l+sep_largeur, 0, w_r, h_d) }
;

drawScene_for_a_viewport(gl, viewport, eye, up, shaderProgram, squareVertexPositionBuffer, repcoords) =
  do Webgl.viewport(gl, viewport.x, viewport.y, viewport.w, viewport.h);
  pMatrix = 
    f = vec3.from_public ;
    tmp_pMatrix = mat4.create();
    do mat4.perspective(45., float_of_int(width) / float_of_int(height), 0.1, 100.0, tmp_pMatrix);
    c = mat4.create() ;
    do mat4.lookAt(f(eye), f((0.0, 0.0, 0.0)), f(up), c);
    do mat4.multiply(tmp_pMatrix, c, tmp_pMatrix);
    tmp_pMatrix;
  mvMatrix = 
    tmp_mvMatrix = mat4.create();
    do mat4.identity(tmp_mvMatrix);
    tmp_mvMatrix;
  do Webgl.uniform1i(gl, shaderProgram.useLightingUniform, 1); // 1 = true
  do Webgl.uniform3f(gl, shaderProgram.ambientColorUniform, 0.4, 0.4, 0.4);
  do Webgl.uniform3f(gl, shaderProgram.lightingDirectionUniform, 0.85, 0.8, 0.75);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), squareVertexPositionBuffer.positions);
  do Webgl.vertexAttribPointer(gl, shaderProgram.vertexPositionAttribute, squareVertexPositionBuffer.itemSize, Webgl.FLOAT(gl), false, 0, 0);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), squareVertexPositionBuffer.normals);
  do Webgl.vertexAttribPointer(gl, shaderProgram.vertexNormalAttribute, squareVertexPositionBuffer.itemSize, Webgl.FLOAT(gl), false, 0, 0);
  do Webgl.bindBuffer(gl, Webgl.ELEMENT_ARRAY_BUFFER(gl), squareVertexPositionBuffer.indexs);
  do setMatrixUniforms(gl, shaderProgram, pMatrix, mvMatrix);
  do Webgl.drawElements(gl, Webgl.TRIANGLES(gl), 36, Webgl.UNSIGNED_SHORT(gl), 0);

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

  void
;

drawScene(gl, shaderProgram, squareVertexPositionBuffer, repcoords) =
  viewbox = setup_boxes() ;
  rec aux(gl, shaderProgram, squareVertexPositionBuffer, repcoords) =
    do Webgl.clear(gl, Webgl.GLbitfield_OR(Webgl.COLOR_BUFFER_BIT(gl), Webgl.DEPTH_BUFFER_BIT(gl)));
    do drawScene_for_a_viewport(gl, viewbox._YX, (0.0, 0.0, 15.0), (0.0, 1.0, 0.0), shaderProgram, squareVertexPositionBuffer, repcoords);
    do drawScene_for_a_viewport(gl, viewbox._YZ, (-15.0, 0.0, 0.0), (0.0, 1.0, 0.0), shaderProgram, squareVertexPositionBuffer, repcoords);
    do drawScene_for_a_viewport(gl, viewbox._ZX, (0.0, -15.0, 0.0), (0.0, 0.0, 1.0), shaderProgram, squareVertexPositionBuffer, repcoords);
    do drawScene_for_a_viewport(gl, viewbox._3D, (15.0, 10.0, 15.0), (0.0, 1.0, 0.0), shaderProgram, squareVertexPositionBuffer, repcoords);
    do RequestAnimationFrame.request((_ -> aux(gl, shaderProgram, squareVertexPositionBuffer, repcoords)), #{id_canvas_area});
    void
    ;
  aux(gl, shaderProgram, squareVertexPositionBuffer, repcoords) 
;

initGL(canvas) : void =
  match Webgl.getContext(canvas, "experimental-webgl") with
  | { some=gl } ->
    squareVertexPositionBuffer = initBuffers(gl);
    repcoords = { x=initLineXBuffers(gl, {x}); y=initLineXBuffers(gl, {y}); z=initLineXBuffers(gl, {z}) };
    shaderProgram = initShaders(gl);
    //Clear screen and make everything black
    do Webgl.clearColor(gl, 0.9, 0.9, 0.9, 1.0);
    //we should do depth testing so that things drawn behind other
    //things should be hidden by the things in front of them).
    do Webgl.clearDepth(gl, 1.0);
    do Webgl.enable(gl, Webgl.DEPTH_TEST(gl));
    do Webgl.depthFunc(gl, Webgl.LEQUAL(gl));
    do drawScene(gl, shaderProgram, squareVertexPositionBuffer, repcoords);
    void
  | { none } -> error("no context found")
  end ;

server_start_static_page() =
  <div>
    <h1>Welcome to this demo</h1>
    <canvas width={width} height={height} id=#{id_canvas_area} onready={_ -> initGL(Dom.of_selection(#{id_canvas_area}))}/>                       
    <div id=#{id_work_area} />
  </div> ;

urls =
  parser
  | (.*) ->
    html("Demo page {Date.to_string(Date.now())}", server_start_static_page())
  end ;


server = simple_server(urls) ;
