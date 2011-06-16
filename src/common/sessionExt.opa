SessionExt =
{{
  make_with_getter(state : 'state, f : 'state, 'msg -> Session.instruction('state)) : (channel('msg), (-> 'state)) =
    ref = Mutable.make(state)
    f_bis(msg) = 
      match f(ref.get(), msg) with
       | ~{set} -> do ref.set(set); {continue}
       | {unchanged} -> {continue}
       | {stop} -> {stop}
    s = Session.make_stateless(f_bis)
    (s, ref.get)

  make_2_side(state : 'state, f1 : 'state, 'msg1 -> Session.instruction('state), f2 : 'state, 'msg2 -> Session.instruction('state)) : (channel('msg1), channel('msg2), (-> 'state)) =
    g(state, message) = 
      match message with | { side1=msg } -> f1(state, msg) | { side2=msg } -> f2(state, msg) end;
    (common, get_state_common) = make_with_getter(state, g);
    s1 = Session.make_callback((msg -> Session.send(common, {side1=msg})));
    s2 = Session.make_callback((msg -> Session.send(common, {side2=msg})));
    (s1, s2, get_state_common)
}}
