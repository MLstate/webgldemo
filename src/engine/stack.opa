
@abstract type stack = list(mat4) ;


Stack = {{ 
  create : (-> stack) = (-> List.empty) ;

  push : (stack, mat4 -> stack) = (s, e -> List.cons(e, s)) ;

  pop : (stack -> stack) = (s ->
    match s : stack with
    | { nil } ->
      do Log.error("Stack", "Stack.pop on a empty list !");
      s
    | { hd=_; ~tl } -> tl
    end) ;

  peek : (stack -> mat4) = (s ->
    match s : stack with
    | { nil } ->
      do Log.error("Stack", "Stack.get on a empty list !");
      mat4.create()
    | { ~hd; tl=_ } -> hd
    end) ;

  update_and_push : (stack, (mat4, mat4 -> void) -> stack) = (s, f ->
    tmp = mat4.create();
    do f(peek(s), tmp);
    Stack.push(s, tmp)) ;

}}
