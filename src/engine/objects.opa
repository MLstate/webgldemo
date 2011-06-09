
type object = { 
  positions: Webgl.WebGLBuffer
  itemSize: int;
  numItems: int;
  normals: Webgl.WebGLBuffer
  indexs: Webgl.WebGLBuffer
}

display(eng, pMatrix, mvMatrix, position, object, overide_color) =
  gl = eng.context; shaderProgram = eng.shaderProgram;
  color = overide_color ? (0.4, 0.4, 0.4);
  do Webgl.uniform3f(gl, shaderProgram.ambientColorUniform, color.f1, color.f2, color.f3);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), object.positions);
  do Webgl.vertexAttribPointer(gl, shaderProgram.vertexPositionAttribute, object.itemSize, Webgl.FLOAT(gl), false, 0, 0);
  do Webgl.bindBuffer(gl, Webgl.ARRAY_BUFFER(gl), object.normals);
  do Webgl.vertexAttribPointer(gl, shaderProgram.vertexNormalAttribute, object.itemSize, Webgl.FLOAT(gl), false, 0, 0);
  do Webgl.bindBuffer(gl, Webgl.ELEMENT_ARRAY_BUFFER(gl), object.indexs);

  mvMatrix = Stack.update_and_push(mvMatrix, (o, n -> mat4.translate(o, vec3.from_public(position), n))) ;
  do setMatrixUniforms(gl, shaderProgram, pMatrix, Stack.peek(mvMatrix));
  do Webgl.drawElements(gl, Webgl.TRIANGLES(gl), 36, Webgl.UNSIGNED_SHORT(gl), 0);
  void
;

Cube = {{
  create(gl) =
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
    { positions=squareVertexPositionBuffer; itemSize=3; numItems=24; normals=squareVertexNormalBuffer; indexs=cubeVertexIndexBuffer } : object
  ;


}}
