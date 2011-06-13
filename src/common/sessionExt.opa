SessionExt =
{{
  make_with_getter(state : 'state, f : 'state, 'msg -> Session.instruction('state)) : (channel('msg), -> 'state) =
    ref = Mutable.make(state)
    f_bis(msg) = 
      match f(ref.get(), msg) with
       | ~{set} -> do ref.set(set); {continue}
       | {unchanged} -> {continue}
       | {stop} -> {stop}
    s = Session.make_stateless(f_bis)
    (s, ref.get)
}}
