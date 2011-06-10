@abstract type hidden_id = int ;

@client CHF : Fresh.next(hidden_id) = Fresh.client((i -> i : hidden_id));

