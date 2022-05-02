-module(streamy_request).
-include_lib("kernel/include/logger.hrl").

-export([install/0, request/3, pending/3]).

-record(streamy_request, {user :: binary(),
                          anime_name :: binary()
                         }).

install() ->
    mnesia_utils:create(streamy_request, record_info(fields, streamy_request),
                        [{type, bag}]).

request(AnimeNameParts, _ApiPid, #{<<"author">> := #{<<"id">> := UserId}}) ->
    AnimeName = bin_join(AnimeNameParts, <<" ">>),
    Entry = #streamy_request{user=UserId, anime_name=AnimeName},
    mnesia:activity(transaction, fun() -> mnesia:write(Entry) end),
    {reply, <<AnimeName/binary, " requested">>, []}.

pending(_Args, _ApiPid, _Data) ->
    F = fun() ->
        mnesia:foldl(fun(X, Acc) -> [element(3, X)|Acc] end,
                     [], streamy_request)
    end,
    Result = mnesia:activity(transaction, F),
    {reply, bin_join([<<"Pending:">>|Result], <<"\n">>), []}.

bin_join([], _Delim) -> <<>>;
bin_join([H|T], Delim) ->
    lists:foldl(fun(X, Acc) -> <<Acc/binary, Delim/binary, X/binary>> end,
                H, T).
