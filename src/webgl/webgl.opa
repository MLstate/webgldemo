
type Webgl.Context.private = external;

type Webgl.Creation.Context = { ok: Webgl.Context.private } / { ko: {GET_A_WEBGL_BROWSER} / {OTHER_PROBLEM} };

type Webgl.WebGLBuffer = external;
type Webgl.WebGLFramebuffer = external;
type Webgl.WebGLRenderbuffer = external;
type Webgl.WebGLTexture = external;
type Webgl.GLenum = external;
type Webgl.Float32Array = external;
type Webgl.Uint16Array = external;
type Webgl.Uint8Array = external;
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
  }}
  Uint8Array = {{
    from_int_list : list(int) -> Webgl.Uint8Array = %% WebglPlugin.Uint8Array_from_int_list %% ;
    to_ArrayBuffer : Webgl.Uint8Array -> Webgl.ArrayBuffer = %% WebglPlugin.Uint8Array_to_ArrayBuffer %% ;
    to_int_list : Webgl.Uint8Array -> list(int) = %% WebglPlugin.Uint8Array_to_int_list %% ;
  }}

  getContext : Dom.private.element, string -> option(Webgl.Context.private) = %% WebglPlugin.getContext %% ;

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
  TEXTURE_MAG_FILTER : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.TEXTURE_MAG_FILTER %% ;
  TEXTURE_MIN_FILTER : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.TEXTURE_MIN_FILTER %% ;
  LINEAR : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.LINEAR %% ;

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

  GLbitfield_OR : Webgl.GLbitfield, Webgl.GLbitfield -> Webgl.GLbitfield = %% WebglPlugin.GLbitfield_OR %% ;
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


  createRenderbuffer : Webgl.Context.private -> Webgl.WebGLRenderbuffer = %% WebglPlugin.createRenderbuffer %% ;
  createTexture : Webgl.Context.private -> Webgl.WebGLTexture = %% WebglPlugin.createTexture %% ;
  bindFramebuffer : Webgl.Context.private, Webgl.GLenum, option(Webgl.WebGLFramebuffer) -> void = %% WebglPlugin.bindFramebuffer %% ;
  bindRenderbuffer : Webgl.Context.private, Webgl.GLenum, option(Webgl.WebGLRenderbuffer) -> void = %% WebglPlugin.bindRenderbuffer %% ;
  bindTexture : Webgl.Context.private, Webgl.GLenum, option(Webgl.WebGLTexture) -> void = %% WebglPlugin.bindTexture %% ;
  texImage2D : Webgl.Context.private, Webgl.GLenum, Webgl.GLint, Webgl.GLenum, Webgl.GLsizei, Webgl.GLsizei, Webgl.GLint, Webgl.GLenum, Webgl.GLenum, Webgl.ArrayBuffer -> void = %% WebglPlugin.texImage2D %% ; // BUG: ArrayBufferView ?
  renderbufferStorage : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLsizei, Webgl.GLsizei -> void = %% WebglPlugin.renderbufferStorage %% ;
  framebufferRenderbuffer : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLenum, Webgl.WebGLRenderbuffer -> void = %% WebglPlugin.framebufferRenderbuffer %% ;
  framebufferTexture2D : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLenum, Webgl.WebGLTexture, Webgl.GLint -> void = %% WebglPlugin.framebufferTexture2D %% ;

  TEXTURE_2D : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.TEXTURE_2D %% ;
  RGB : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.RGB %% ;
  RGBA : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.RGBA %% ;
  UNSIGNED_BYTE : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.UNSIGNED_BYTE %% ;
  FRAMEBUFFER : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.FRAMEBUFFER %% ;
  RENDERBUFFER : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.RENDERBUFFER %% ;
  DEPTH_COMPONENT16 : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.DEPTH_COMPONENT16 %% ;
  COLOR_ATTACHMENT0 : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.COLOR_ATTACHMENT0 %% ;
  DEPTH_ATTACHMENT : Webgl.Context.private -> Webgl.GLenum = %% WebglPlugin.DEPTH_ATTACHMENT %% ;

  createFramebuffer : Webgl.Context.private -> Webgl.WebGLFramebuffer = %% WebglPlugin.createFramebuffer %% ;

  readPixels : Webgl.Context.private, Webgl.GLint, Webgl.GLint, Webgl.GLsizei, Webgl.GLsizei, Webgl.GLenum, Webgl.GLenum, Webgl.ArrayBuffer -> void = %% WebglPlugin.readPixels %% ;


  texParameterf : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLfloat -> void = %% WebglPlugin.texParameterf %% ;
  texParameteri : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLint -> void = %% WebglPlugin.texParameteri %% ;

  GLenum_to_GLint : Webgl.Context.private, Webgl.GLenum -> Webgl.GLint = %% WebglPlugin.GLenum_to_GLint %% ;

}}
