@abstract type hidden_id = (int, int) ;

type patch_id = hidden_id;

build_CPF(F : Fresh.next(int), client_id : int) : Fresh.next(hidden_id) = (-> (F(), client_id));

get_client_id_from_patch_id(pid : patch_id) : int = pid.f2;
