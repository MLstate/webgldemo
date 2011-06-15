

type notify('a) =
  { si : (-> bool); then_do : ('a -> void); else_autoclean } ;

@abstract type subject('a) =
  { state : 'a
  ; viewers : channel( {attach : notify('a)} / {propagate : 'a} / {check : 'a})
  ; id : int
  } ;


Observable =

  sl(g : -> void) = sleep(1, g) ;

  make(a : 'a) = (
    randomize_list(l : list) : list = List.sort_by((_ -> Random.int(300)), l);
    id = Random.int(100000) ;
    f(state : 'state, msg : 'msg) : Session.instruction('state) = (
      match msg with
      | { check=fun_val_a } ->
        {} =
          if (fun_val_a != state.recall) then
            Log.warning("TT", "(#17982) WARNING in Observable, a 'functional' subject is out of synchronisation with his session state") ;
        { unchanged }
      | { attach=f } ->
        // here we do not test if the notifier exists
        {} = sl(-> f.then_do(state.recall)) ;
        { set={ state with stack = List.cons(f, state.stack) } }
      | { propagate=na } ->
        //{} = ttlog(">> propagate id='{id}'") ;
        {} =
          state =
            new_stack =
              filter(z : notify) = if z.si() then Option.some(z) else Option.none ;
              List.filter_map(filter, state.stack) ;
            { state with stack=new_stack } ;
          tmp() =
            h_iter(notify) = (
              //{} = ttlog("< propagate id='{id}'");
              notify.then_do(na)) ;
            List.iter(h_iter, randomize_list(state.stack)) ;
          sl(tmp) ;
        { set={ state with recall=na } }
      end );
    viewers = Session.make({ stack=List.empty; recall=a }, f) ;
    { state=a; ~viewers; ~id } : subject );


  get_state(c : subject('a)) : 'a =
    tmp = c.state ;
    {} = Session.send((c).viewers, {check=tmp})
    tmp ;

  register(obs : notify('a), c : subject('a)) : void =
    Session.send((c).viewers, { attach=obs }) ;

  change_state(x : 'a, c : subject('a)) : subject('a) = (
    //{} = ttlog("change state to '{magic_serialize(x)}'  ;  \"id={magic_serialize(c.id)}\"") ;
    {} = Session.send((c).viewers, { propagate=x }) ;
    { c with state=x } : subject );

  get_id(c : subject('a)) : int = (c).id ;

  { ~make
  ; ~get_state
  ; ~register
  ; ~change_state
  ; ~get_id
  } ;
// end of Observable

