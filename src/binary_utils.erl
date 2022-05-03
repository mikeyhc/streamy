-module(binary_utils).

-export([bin_join/2]).

bin_join([], _Delim) -> <<>>;
bin_join([H|T], Delim) ->
    lists:foldl(fun(X, Acc) -> <<Acc/binary, Delim/binary, X/binary>> end,
                H, T).
