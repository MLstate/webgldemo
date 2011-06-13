##opa-type Dom.private.element

##extern-type Webgl.Context.private

##register setupWebGL: Dom.private.element -> opa[ option(Webgl.Context.private) ]
##args(canvas)
{ return js2option(WebGLUtils.setupWebGL(canvas)); }

##extern-type Webgl.Creation.Context

##register setupWebGL_with_custom_failure: Dom.private.element -> opa[ Webgl.Creation.Context ]
##args(canvas)
{
  if (!window.WebGLRenderingContext) {
      return { ko: {GET_A_WEBGL_BROWSER: null} };
  }

  var opt_attribs = null;
  var context = create3DContext(canvas, opt_attribs);
  if (!context) {
      return { ko: {OTHER_PROBLEM: null} };
  } else {
    return context;
  }
}