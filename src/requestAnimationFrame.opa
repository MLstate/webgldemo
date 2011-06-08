
RequestAnimationFrame = {{
                        
  request(callback : Date.date -> void, dom : dom) : void =
    concrete = Dom.of_selection(dom)
    cb_bis(x) = callback(Date.milliseconds(x))
    (%%RequestAnimationFramePlugin.requestAnimationFrame%%)(cb_bis, concrete) ;

}}
