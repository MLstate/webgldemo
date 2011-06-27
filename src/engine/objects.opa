
type engine.color = ColorFloat.color;
type engine.position = vec3;

type object.pickable = { 
  vertexPositions: Webgl.WebGLBuffer;
  itemSize: int;
  numItems: int;
  vertexNormals: Webgl.WebGLBuffer;
  vertexIndexs: Webgl.WebGLBuffer;
  picking_color: engine.color;
  id: hidden_id;
  color: engine.color;
  position: engine.position;
  is_selected: bool;
  beginMode: Webgl.GLenum;
  numIndexs: int
}

type object.simple = {
  positions: Webgl.WebGLBuffer;
  itemSize: int; numItems: int;
  beginMode: Webgl.GLenum;
  color: engine.color;
};

type object = object.pickable;

display_simple(eng, object : object.simple) =
  rec gl = eng.context and color = object.color and shaderProgram = eng.shaderProgram;
  do Webgl.uniform3f(gl, shaderProgram.ambientColorUniform, color.f1, color.f2, color.f3);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), object.positions);
  do Webgl.vertexAttribPointer(gl, shaderProgram.vertexPositionAttribute, object.itemSize, Webgl.FLOAT(gl), false, 0, 0);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), object.positions);
  do Webgl.vertexAttribPointer(gl, shaderProgram.vertexNormalAttribute, object.itemSize, Webgl.FLOAT(gl), false, 0, 0);
  do Webgl.drawArrays(gl, Webgl.LINES(gl), 0, object.numItems);
  void ;

Lines = {{
  create(gl, vertices, color) =
    vertexPositionBuffer = Webgl.createBuffer(gl);
    do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), vertexPositionBuffer);
    do Webgl.bufferData(gl, Webgl.ARRAY_BUFFER(gl),
      Webgl.Float32Array.to_ArrayBuffer(Webgl.Float32Array.from_float_list(vertices)),
      Webgl.STATIC_DRAW(gl));
    itemSize = 3;
    do @assert(mod(List.length(vertices), itemSize) == 0);
    { positions=vertexPositionBuffer; ~itemSize; numItems=List.length(vertices) / itemSize; beginMode=Webgl.LINES(gl); ~color }

  grid(gl, right : int, left : int, by : int, len : float, maper, color) =
    right = (right / by : int) * by;
    left = (left / by : int) * by;
    state =
      f(state : 'state) : 'state =
        tmp = (float_of_int(state.i), len, float_of_int(state.i), -len)
        { l=List.cons(tmp, state.l); i=state.i + by };
      g(state) : bool = state.i <= left;
      for({i=right; l=List.empty}, f, g);
    l_a = List.flatten(List.map(((a, b, c, d) -> List.append(maper(a, b), maper(c, d)) ), state.l));
    l_b = List.flatten(List.map(((a, b, c, d) -> List.append(maper(b, a), maper(d, c)) ), state.l));
    create(gl, List.append(l_a, l_b) : list(float), color);

}}

display_pickable(eng, pMatrix, mvMatrix, object : object.pickable, overide_color_for_picking) =
  gl = eng.context; shaderProgram = eng.shaderProgram;
  color = 
    if overide_color_for_picking then object.picking_color 
    else if object.is_selected then (0.7, 0., 0.) else object.color;
  do Webgl.uniform3f(gl, shaderProgram.ambientColorUniform, color.f1, color.f2, color.f3);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), object.vertexPositions);
  do Webgl.vertexAttribPointer(gl, shaderProgram.vertexPositionAttribute, object.itemSize, Webgl.FLOAT(gl), false, 0, 0);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), object.vertexNormals);
  do Webgl.vertexAttribPointer(gl, shaderProgram.vertexNormalAttribute, object.itemSize, Webgl.FLOAT(gl), false, 0, 0);
  do Webgl.bindBuffer(gl, Webgl.ELEMENT_ARRAY_BUFFER(gl), object.vertexIndexs);

  mvMatrix = Stack.update_and_push(mvMatrix, (o -> mat4.translate(o, vec3.from_public(object.position)))) ;
  do setMatrixUniforms(gl, shaderProgram, pMatrix, Stack.peek(mvMatrix));
  do Webgl.drawElements(gl, object.beginMode, object.numIndexs, Webgl.UNSIGNED_SHORT(gl), 0);
  void
;

Cube = {{
  create(gl, m_object : Scene.objects, is_selected) : object =
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
    //global variable to hold the cube buffer
    //We create a buffer for the cube's vertex positions.
    cubeVertexPositionBuffer = Webgl.createBuffer(gl);
    //tells WebGL that any following operations that act on buffers should use the one we specify
    do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), cubeVertexPositionBuffer);
    //Now, we create a Float32Array object based on our list, 
    //and tell WebGL to use it to fill the current buffer
    do Webgl.bufferData(gl, Webgl.ARRAY_BUFFER(gl), Webgl.Float32Array.to_ArrayBuffer(Webgl.Float32Array.from_float_list(vertices)), Webgl.STATIC_DRAW(gl));
    cubeVertexNormalBuffer = Webgl.createBuffer(gl);
    do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), cubeVertexNormalBuffer);
    do Webgl.bufferData(gl, Webgl.ARRAY_BUFFER(gl), Webgl.Float32Array.to_ArrayBuffer(Webgl.Float32Array.from_float_list(vertexNormals)), Webgl.STATIC_DRAW(gl));
    cubeVertexIndexBuffer = Webgl.createBuffer(gl);
    do Webgl.bindBuffer(gl, Webgl.ELEMENT_ARRAY_BUFFER(gl), cubeVertexIndexBuffer);
    do Webgl.bufferData(gl, Webgl.ELEMENT_ARRAY_BUFFER(gl), Webgl.Uint16Array.to_ArrayBuffer(Webgl.Uint16Array.from_int_list(cubeVertexIndices)), Webgl.STATIC_DRAW(gl));
    { vertexPositions=cubeVertexPositionBuffer; itemSize=3; numItems=24; vertexNormals=cubeVertexNormalBuffer; vertexIndexs=cubeVertexIndexBuffer; picking_color=ColorFloat.random(); id=m_object.id; color=m_object.color
    ; ~is_selected; position=m_object.cube; beginMode=Webgl.TRIANGLES(gl); numIndexs=36 } : object
  ;


}}
