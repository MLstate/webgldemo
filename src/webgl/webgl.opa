
type Webgl.Context.private = external;

type Webgl.WebGLBuffer = external;
type Webgl.GLenum = external;
type Webgl.Float32Array = external;//llarray(float);
type Webgl.Uint16Array = external;
type Webgl.ArrayBuffer = external;
type Webgl.DOMString = string;
type Webgl.WebGLShader = external;
type Webgl.WebGLProgram = external;
type Webgl.WebGLUniformLocation = external;
type Webgl.GLuint = int; //typedef unsigned long  GLuint;
type Webgl.GLint = int; //typedef long           GLint;
type Webgl.GLbitfield = int; //typedef unsigned long GLbitfield;
type Webgl.GLclampf = float; //typedef float          GLclampf; 
type Webgl.GLsizei = int; //typedef long           GLsizei;
type Webgl.GLintptr = int; //BUG //typedef long long      GLintptr;
type Webgl.GLfloat = float; //BUG 32 bit ?
type Webgl.GLboolean = bool; //typedef boolean        GLboolean;

Webgl = {{
  Uint16Array = {{
    from_int_list : list(int) -> Webgl.Uint16Array = %% WebglPlugin.Uint16Array_from_int_list %% ;
    to_ArrayBuffer : Webgl.Uint16Array -> Webgl.ArrayBuffer = %% WebglPlugin.Uint16Array_to_ArrayBuffer %% ;
  }}
  Float32Array = {{
    from_float_list : list(float) -> Webgl.Float32Array = %% WebglPlugin.Float32Array_from_float_list %% ;
    to_ArrayBuffer : Webgl.Float32Array -> Webgl.ArrayBuffer = %% WebglPlugin.Float32Array_to_ArrayBuffer %% ;
    to_float_list : Webgl.Float32Array -> list(float) = %% WebglPlugin.Float32Array_to_float_list %% ;
  }}

  getContext : Dom.private.element, string -> option(Webgl.Context.private) = %% WebglPlugin.getContext %% ;

  set_viewportWidth : Webgl.Context.private, int -> void = %% WebglPlugin.set_viewportWidth %% ;
  get_viewportWidth : Webgl.Context.private -> int = %% WebglPlugin.get_viewportWidth %% ;
  set_viewportHeight : Webgl.Context.private, int -> void = %% WebglPlugin.set_viewportHeight %% ;
  get_viewportHeight : Webgl.Context.private -> int = %% WebglPlugin.get_viewportHeight %% ;

  createBuffer : Webgl.Context.private -> Webgl.WebGLBuffer = %% WebglPlugin.createBuffer %% ;
  set_itemSize : Webgl.WebGLBuffer, int -> void = %% WebglPlugin.set_itemSize %%;
  set_numItems : Webgl.WebGLBuffer, int -> void = %% WebglPlugin.set_numItems %%;

  ARRAY_BUFFER : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.ARRAY_BUFFER %% ;
  STATIC_DRAW : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.STATIC_DRAW %% ;
  FRAGMENT_SHADER : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.FRAGMENT_SHADER %% ;
  VERTEX_SHADER : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.VERTEX_SHADER %% ;
  DEPTH_TEST : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.DEPTH_TEST %% ;
  LEQUAL : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.LEQUAL %% ;
  FLOAT : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.FLOAT %% ;
  UNSIGNED_SHORT : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.UNSIGNED_SHORT %% ;
  LINES : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.LINES %% ;
  TRIANGLES : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.TRIANGLES %% ;
  TRIANGLE_STRIP : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.TRIANGLE_STRIP %% ;
  ELEMENT_ARRAY_BUFFER : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.ELEMENT_ARRAY_BUFFER %% ;

  bindBuffer : Webgl.Context.private, Webgl.GLenum, Webgl.WebGLBuffer -> void = %% WebglPlugin.bindBuffer %% ;

  bufferData : Webgl.Context.private, Webgl.GLenum, Webgl.ArrayBuffer, Webgl.GLenum -> void = %% WebglPlugin.bufferData %% ;

  shaderSource : Webgl.Context.private, Webgl.WebGLShader, Webgl.DOMString -> void = %% WebglPlugin.shaderSource %% ;

  createShader : Webgl.Context.private, Webgl.GLenum -> Webgl.WebGLShader = %% WebglPlugin.createShader %% ;

  compileShader : Webgl.Context.private, Webgl.WebGLShader -> void = %% WebglPlugin.compileShader %%;

  createProgram : Webgl.Context.private -> Webgl.WebGLProgram = %% WebglPlugin.createProgram %% ;
  attachShader : Webgl.Context.private, Webgl.WebGLProgram, Webgl.WebGLShader -> void = %% WebglPlugin.attachShader %% ;
  linkProgram : Webgl.Context.private, Webgl.WebGLProgram -> void = %% WebglPlugin.linkProgram %% ;
  useProgram : Webgl.Context.private, Webgl.WebGLProgram -> void = %% WebglPlugin.useProgram %% ;
  getAttribLocation : Webgl.Context.private, Webgl.WebGLProgram, Webgl.DOMString -> Webgl.GLint = %% WebglPlugin.getAttribLocation %% ;
  enableVertexAttribArray : Webgl.Context.private, Webgl.GLuint -> void = %% WebglPlugin.enableVertexAttribArray %% ;
  getUniformLocation : Webgl.Context.private, Webgl.WebGLProgram, Webgl.DOMString -> Webgl.WebGLUniformLocation = %% WebglPlugin.getUniformLocation %% ;

  clear : Webgl.Context.private, Webgl.GLbitfield -> void = %% WebglPlugin.clear %% ;
  clearColor : Webgl.Context.private, Webgl.GLclampf, Webgl.GLclampf, Webgl.GLclampf, Webgl.GLclampf -> void = %% WebglPlugin.clearColor %% ;
  enable : Webgl.Context.private, Webgl.GLenum -> void = %% WebglPlugin.enable %% ;

  clearDepth : Webgl.Context.private, Webgl.GLclampf -> void = %% WebglPlugin.clearDepth %% ;
  depthFunc : Webgl.Context.private, Webgl.GLenum -> void = %% WebglPlugin.depthFunc %% ;

  viewport : Webgl.Context.private, Webgl.GLint, Webgl.GLint, Webgl.GLsizei, Webgl.GLsizei -> void = %% WebglPlugin.viewport %% ;

  
  DEPTH_BUFFER_BIT : Webgl.Context.private -> Webgl.GLbitfield = %% WebglPlugin.DEPTH_BUFFER_BIT %% ;
  STENCIL_BUFFER_BIT : Webgl.Context.private -> Webgl.GLbitfield = %% WebglPlugin.STENCIL_BUFFER_BIT %% ;
  COLOR_BUFFER_BIT : Webgl.Context.private -> Webgl.GLbitfield = %% WebglPlugin.COLOR_BUFFER_BIT %% ;

  vertexAttribPointer : Webgl.Context.private, Webgl.GLuint, Webgl.GLint, Webgl.GLenum, Webgl.GLboolean, Webgl.GLsizei, Webgl.GLintptr -> void = %% WebglPlugin.vertexAttribPointer %% ;
  drawArrays : Webgl.Context.private, Webgl.GLenum, Webgl.GLint, Webgl.GLsizei -> void = %% WebglPlugin.drawArrays %% ;
  drawElements : Webgl.Context.private, Webgl.GLenum, Webgl.GLsizei, Webgl.GLenum, Webgl.GLintptr -> void = %% WebglPlugin.drawElements %% ;
  uniform1i : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.GLint -> void = %% WebglPlugin.uniform1i %% ;
  uniform4fv : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.Float32Array -> void = %% WebglPlugin.uniform4fv %% ;
  uniformMatrix3fv : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.GLboolean, Webgl.Float32Array -> void = %% WebglPlugin.uniformMatrix3fv %% ;
  uniformMatrix4fv : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.GLboolean, Webgl.Float32Array -> void = %% WebglPlugin.uniformMatrix4fv %% ;
  uniform3f : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.GLfloat, Webgl.GLfloat, Webgl.GLfloat -> void = %% WebglPlugin.uniform3f %% ;

}}

truc_fs : Webgl.Context.private -> Webgl.WebGLShader = %% WebglPlugin.truc_fs %% ;
truc_vs : Webgl.Context.private -> Webgl.WebGLShader = %% WebglPlugin.truc_vs %% ;
plop : Webgl.Context.private, Webgl.WebGLUniformLocation, mat4, Webgl.WebGLUniformLocation, mat4, Webgl.GLboolean -> void = %% WebglPlugin.plop %% ;
my_uniformMatrix4fv : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.GLboolean, mat4 -> void = %% WebglPlugin.my_uniformMatrix4fv %% ;
