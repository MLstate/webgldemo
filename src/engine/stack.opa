
@abstract type stack = list(mat4) ;


Stack = {{ 
  create : (-> stack) = (-> List.empty) ;

  push : (stack, mat4 -> stack) = (s, e -> List.cons(e, s)) ;

  pop : (stack -> (stack, mat4)) = (s ->
    match s : stack with
    | { nil } -> 
      do Log.error("Stack", "Stack.pop on a empty list !");
      (s, mat4.create())
    | { ~hd; ~tl } -> (tl, hd)
    end) ;

  get : (stack -> mat4) = (s ->
    match s : stack with
    | { nil } -> 
      do Log.error("Stack", "Stack.get on a empty list !");
      mat4.create()
    | { ~hd; tl=_ } -> hd
    end) ;

  update : (stack, (mat4, mat4 -> void) -> stack) = (s, f ->
    tmp = mat4.create();
    do f(get(s), tmp);
    Stack.push(s, tmp)) ;

}}
