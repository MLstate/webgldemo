##opa-type Dom.private.element


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
