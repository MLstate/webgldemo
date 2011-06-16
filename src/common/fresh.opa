@abstract type hidden_id = int ;

@client CHF : Fresh.next(hidden_id) = Fresh.client((i -> i : hidden_id));

@abstract type patch_id = (int, int) ;

@client build_CPF(client_id : int) : Fresh.next(patch_id) =
  Fresh.client((i -> (i, client_id): patch_id));


