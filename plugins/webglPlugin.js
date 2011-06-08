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


##register set_viewportWidth : Webgl.Context.private, int -> void
##args(gl, width)
{ return gl.viewportWidth = width; }
##register get_viewportWidth : Webgl.Context.private -> int
##args(gl)
{ return gl.viewportWidth; }

##register set_viewportHeight : Webgl.Context.private, int -> void
##args(gl, height)
{ return gl.viewportHeight = height; }
##register get_viewportHeight : Webgl.Context.private -> int
##args(gl)
{ return gl.viewportHeight; }

##extern-type Webgl.WebGLBuffer

##register createBuffer : Webgl.Context.private -> Webgl.WebGLBuffer
##args(gl)
{ return gl.createBuffer(); }
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
{ var y = "piloupiloupiloupilou"; return new Float32Array(list2js(l)); }
##register Float32Array_to_ArrayBuffer : Webgl.Float32Array -> Webgl.ArrayBuffer
##args(a)
{ return a; }

##register Float32Array_to_float_list : Webgl.Float32Array -> list(float)
##args(b)
{ return js2list(b); }

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
