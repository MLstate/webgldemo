##opa-type Dom.private.element
##opa-type list('a)

##extern-type Webgl.Context.private

##register getContext : Dom.private.element, string -> opa[ option(Webgl.Context.private) ]
##args(canvas, name)
{
    if(canvas && canvas[0] && canvas[0].getContext) {
	var tmp = canvas[0].getContext(name);
        if (tmp) { 
	    return js_some(tmp) ;
	} else {
	    return js_none;
	}
    };
    return js_none
}


##extern-type Webgl.WebGLBuffer

##register createBuffer : Webgl.Context.private -> Webgl.WebGLBuffer
##args(gl)
{ return gl.createBuffer(); }

##extern-type Webgl.WebGLFramebuffer

##register createFramebuffer : Webgl.Context.private -> Webgl.WebGLFramebuffer
##args(gl)
{ return gl.createFramebuffer(); }



##register set_itemSize : Webgl.WebGLBuffer, int -> void
##args(buffer, x)
{ return buffer.itemSize = x; }
##register set_numItems : Webgl.WebGLBuffer, int -> void
##args(buffer, x)
{ return buffer.numItems = x; }

##extern-type Webgl.GLenum

##register ARRAY_BUFFER : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.ARRAY_BUFFER; }
##register STATIC_DRAW : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.STATIC_DRAW; }
##register FRAGMENT_SHADER : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.FRAGMENT_SHADER; }
##register VERTEX_SHADER : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.VERTEX_SHADER; }
##register DEPTH_TEST : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.DEPTH_TEST; }
##register LEQUAL : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.LEQUAL; }
##register FLOAT : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.FLOAT; }
##register UNSIGNED_SHORT : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.UNSIGNED_SHORT; }
##register TRIANGLE_STRIP : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.TRIANGLE_STRIP; }
##register LINES : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.LINES; }
##register TRIANGLES : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.TRIANGLES; }
##register ELEMENT_ARRAY_BUFFER : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.ELEMENT_ARRAY_BUFFER; }
##register TEXTURE_MAG_FILTER : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.TEXTURE_MAG_FILTER; }
##register TEXTURE_MIN_FILTER : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.TEXTURE_MIN_FILTER; }
##register LINEAR : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.LINEAR; }

##register bindBuffer : Webgl.Context.private, Webgl.GLenum, Webgl.WebGLBuffer -> void
##args(gl, target, buff)
{ return gl.bindBuffer(target, buff); }

##extern-type Webgl.ArrayBuffer
##extern-type Webgl.Uint16Array

##register Uint16Array_from_int_list : opa[ list(int) ] -> Webgl.Uint16Array
##args(l)
{ return new Uint16Array(list2js(l)); }
##register Uint16Array_to_ArrayBuffer : Webgl.Uint16Array -> Webgl.ArrayBuffer
##args(a)
{ return a; }

##extern-type Webgl.Float32Array

##register Float32Array_from_float_list : opa[ list(float) ] -> Webgl.Float32Array
##args(l)
{ return new Float32Array(list2js(l)); }
##register Float32Array_to_ArrayBuffer : Webgl.Float32Array -> Webgl.ArrayBuffer
##args(a)
{ return a; }

##extern-type Webgl.Uint8Array

##register Uint8Array_from_int_list : opa[ list(int) ] -> Webgl.Uint8Array
##args(l)
{ return new Uint8Array(list2js(l)); }
##register Uint8Array_to_ArrayBuffer : Webgl.Uint8Array -> Webgl.ArrayBuffer
##args(a)
{ return a; }
##register Uint8Array_to_int_list : Webgl.Uint8Array -> opa[ list(int) ]
##args(a)
{ return js2list(a); }


##register bufferData : Webgl.Context.private, Webgl.GLenum, Webgl.ArrayBuffer, Webgl.GLenum -> void
##args(gl, target, data, usage)
{ return gl.bufferData(target, data, usage); }

##opa-type Webgl.DOMString
##extern-type Webgl.WebGLShader

##register shaderSource : Webgl.Context.private, Webgl.WebGLShader, Webgl.DOMString -> void
##args(gl, shader, source)
{ return gl.shaderSource(shader, source); }

##register createShader : Webgl.Context.private, Webgl.GLenum -> Webgl.WebGLShader
##args(gl, type)
{ return gl.createShader(type); }


##register compileShader : Webgl.Context.private, Webgl.WebGLShader -> void
##args(gl, shader)
{ return gl.compileShader(shader); }


##extern-type Webgl.WebGLProgram
##extern-type Webgl.WebGLUniformLocation
//typedef unsigned long  GLuint;
##opa-type Webgl.GLuint 

##register createProgram : Webgl.Context.private -> Webgl.WebGLProgram
##args(gl)
{ return gl.createProgram(); }

##register attachShader : Webgl.Context.private, Webgl.WebGLProgram, Webgl.WebGLShader -> void
##args(gl, program, shader)
{ return gl.attachShader(program, shader); }

##register linkProgram : Webgl.Context.private, Webgl.WebGLProgram -> void
##args(gl, program)
{ return gl.linkProgram(program); }

##register useProgram : Webgl.Context.private, Webgl.WebGLProgram -> void
##args(gl, program)
{ return gl.useProgram(program); }

//typedef long           GLint;
##extern-type Webgl.GLint

##register getAttribLocation : Webgl.Context.private, Webgl.WebGLProgram, Webgl.DOMString -> Webgl.GLint
##args(gl, program, name)
{ return gl.getAttribLocation(program, name); }

##register enableVertexAttribArray : Webgl.Context.private, Webgl.GLuint -> void
##args(gl, index)
{ return gl.enableVertexAttribArray(index); }

##register getUniformLocation : Webgl.Context.private, Webgl.WebGLProgram, Webgl.DOMString -> Webgl.WebGLUniformLocation
##args(gl, program, name)
{ return gl.getUniformLocation(program, name); }

//typedef unsigned long GLbitfield;
##extern-type Webgl.GLbitfield
//typedef float          GLclampf; 
##extern-type Webgl.GLclampf

##register clear : Webgl.Context.private, Webgl.GLbitfield -> void
##args(gl, mask)
{ return gl.clear(mask); }

##register clearColor : Webgl.Context.private, Webgl.GLclampf, Webgl.GLclampf, Webgl.GLclampf, Webgl.GLclampf -> void
##args(gl, red, green, blue, alpha)
{ return gl.clearColor(red, green, blue, alpha); }

##register enable : Webgl.Context.private, Webgl.GLenum -> void
##args(gl, cap)
{ return gl.enable(cap); }

##register clearDepth : Webgl.Context.private, Webgl.GLclampf -> void
##args(gl, depth)
{ return gl.clearDepth(depth); }

##register depthFunc : Webgl.Context.private, Webgl.GLenum -> void
##args(gl, func)
{ return gl.depthFunc(func); }

//typedef long           GLsizei;
##extern-type Webgl.GLsizei

##register viewport : Webgl.Context.private, Webgl.GLint, Webgl.GLint, Webgl.GLsizei, Webgl.GLsizei -> void
##args(gl, x, y, width, height)
{ gl.viewport(x, y, width, height); }


##register GLbitfield_OR : Webgl.GLbitfield, Webgl.GLbitfield -> Webgl.GLbitfield
##args(a, b)
{ return (a | b); }

/* ClearBufferMask */
##register DEPTH_BUFFER_BIT : Webgl.Context.private -> Webgl.GLbitfield
##args(gl)
{ return gl.DEPTH_BUFFER_BIT; }
##register STENCIL_BUFFER_BIT : Webgl.Context.private -> Webgl.GLbitfield
##args(gl)
{ return gl.STENCIL_BUFFER_BIT; }
##register COLOR_BUFFER_BIT : Webgl.Context.private -> Webgl.GLbitfield
##args(gl)
{ return gl.COLOR_BUFFER_BIT; }

##opa-type Webgl.GLintptr
##opa-type Webgl.GLboolean

##register vertexAttribPointer : Webgl.Context.private, Webgl.GLuint, Webgl.GLint, Webgl.GLenum, Webgl.GLboolean, Webgl.GLsizei, Webgl.GLintptr -> void
##args(gl, indx, size, type, normalized, stride, offset)
{ gl.vertexAttribPointer(indx, size, type, normalized, stride, offset); }

##register drawArrays : Webgl.Context.private, Webgl.GLenum, Webgl.GLint, Webgl.GLsizei -> void
##args(gl, mode, first, count)
{ gl.drawArrays(mode, first, count); }

##register drawElements : Webgl.Context.private, Webgl.GLenum, Webgl.GLsizei, Webgl.GLenum, Webgl.GLintptr -> void
##args(gl, mode, count, type, offset)
{ gl.drawElements(mode, count, type, offset); }

##register uniform1i : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.GLint -> void
##args(gl, location, x)
{ gl.uniform1i(location, x); }

##register uniform4fv : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.Float32Array -> void
##args(gl, location, v)
{ gl.uniform4fv(location, v); }

##register uniformMatrix3fv : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.GLboolean, Webgl.Float32Array -> void
##args(gl, location, transpose, value)
{ gl.uniformMatrix3fv(location, transpose, value); }

##register uniformMatrix4fv : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.GLboolean, Webgl.Float32Array -> void
##args(gl, location, transpose, value)
{ gl.uniformMatrix4fv(location, transpose, value); }

##opa-type Webgl.GLfloat

##register uniform3f : Webgl.Context.private, Webgl.WebGLUniformLocation, Webgl.GLfloat, Webgl.GLfloat, Webgl.GLfloat -> void
##args(gl, location, x, y, z)
{ gl.uniform3f(location, x, y, z); }


##extern-type Webgl.WebGLRenderbuffer
##extern-type Webgl.WebGLTexture

##register createRenderbuffer : Webgl.Context.private -> Webgl.WebGLRenderbuffer
##args(gl)
{ return gl.createRenderbuffer(); }
##register createTexture : Webgl.Context.private -> Webgl.WebGLTexture
##args(gl)
{ return gl.createTexture(); }
##register bindFramebuffer : Webgl.Context.private, Webgl.GLenum, opa[ option(Webgl.WebGLFramebuffer) ] -> void
##args(gl, target, framebuffer)
{ gl.bindFramebuffer(target, option2js(framebuffer)); }
##register bindRenderbuffer : Webgl.Context.private, Webgl.GLenum, opa[ option(Webgl.WebGLRenderbuffer) ] -> void
##args(gl, target, renderbuffer)
{ gl.bindRenderbuffer(target, option2js(renderbuffer)); }
##register bindTexture : Webgl.Context.private, Webgl.GLenum, opa[ option(Webgl.WebGLTexture) ] -> void
##args(gl, target, texture)
{ gl.bindTexture(target, option2js(texture)); }
##register texImage2D : Webgl.Context.private, Webgl.GLenum, Webgl.GLint, Webgl.GLenum,\
	   Webgl.GLsizei, Webgl.GLsizei, Webgl.GLint, Webgl.GLenum, Webgl.GLenum, Webgl.ArrayBuffer -> void 
// BUG: ArrayBufferView ?
// TODO: pixel en option
##args(gl, target, level, internalformat, width, height, border, format, type, pixels)
{ gl.texImage2D(target, level, internalformat, width, height, border, format, type, null); }
##register renderbufferStorage : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLsizei, Webgl.GLsizei -> void
##args(gl, target, internalformat, width, height)
{ gl.renderbufferStorage(target, internalformat, width, height); }
##register framebufferRenderbuffer : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLenum, Webgl.WebGLRenderbuffer -> void
##args(gl, target, attachment, renderbuffertarget, renderbuffer)
{ gl.framebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer); }
##register framebufferTexture2D : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLenum, Webgl.WebGLTexture, Webgl.GLint -> void
##args(gl, target, attachment, textarget, texture, level)
{ gl.framebufferTexture2D(target, attachment, textarget, texture, level); }


##register TEXTURE_2D : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.TEXTURE_2D; }
##register RGB : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.RGB; }
##register RGBA : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.RGBA; }
##register UNSIGNED_BYTE : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.UNSIGNED_BYTE; }
##register FRAMEBUFFER : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.FRAMEBUFFER; }
##register RENDERBUFFER : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.RENDERBUFFER; }
##register DEPTH_COMPONENT16 : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.DEPTH_COMPONENT16; }
##register COLOR_ATTACHMENT0 : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.COLOR_ATTACHMENT0; }
##register DEPTH_ATTACHMENT : Webgl.Context.private -> Webgl.GLenum
##args(gl)
{ return gl.DEPTH_ATTACHMENT; }

##register readPixels : Webgl.Context.private, Webgl.GLint, Webgl.GLint, Webgl.GLsizei, Webgl.GLsizei, Webgl.GLenum, Webgl.GLenum, Webgl.ArrayBuffer -> void
##args(gl, x, y, width, height, format, type, pixels)
{ gl.readPixels(x, y, width, height, format, type, pixels); }


##register texParameterf : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLfloat -> void
##args(gl, target, pname, param)
{ gl.texParameteri(target, pname, param); }
##register texParameteri : Webgl.Context.private, Webgl.GLenum, Webgl.GLenum, Webgl.GLint -> void
##args(gl, target, pname, param)
{ gl.texParameteri(target, pname, param); }

##register GLenum_to_GLint : Webgl.Context.private, Webgl.GLenum -> Webgl.GLint
##args(gl, e)
{ return e; }
