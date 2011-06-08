
##extern-type Dom.private.element

##register requestAnimationFrame : (int -> void), Dom.private.element -> void
##args(callback, dom)
{
    var items = dom.get();
    var len = items.length;
    for(var i = 0; i < len; ++i)
       window.requestAnimationFrame(callback, items[i]);
    return js_void;
}
