@abstract type hidden_id = int ;

@abstract type patch_id = (int, int) ;

build_CPF(F, client_id : int) : Fresh.next(patch_id) = (-> (F(), client_id));


