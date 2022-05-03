-module(streamy_request).
-include_lib("kernel/include/logger.hrl").

-export([install/0, request/3, pending/3]).

-record(streamy_request, {user :: binary(),
                          show_name :: binary()
                         }).

install() ->
    mnesia_utils:create(streamy_request, record_info(fields, streamy_request),
                        [{type, bag}]).

request(ShowNameParts, _ApiPid, #{<<"author">> := #{<<"id">> := UserId}}) ->
    ShowName = binary_utils:bin_join(ShowNameParts, <<" ">>),
    Entry = #streamy_request{user=UserId, show_name=ShowName},
    mnesia_utils:write(Entry),
    {reply, <<ShowName/binary, " requested">>, []}.

pending(_Args, _ApiPid, _Data) ->
    F = fun() ->
        mnesia:foldl(fun(X, Acc) -> [element(3, X)|Acc] end,
                     [], streamy_request)
    end,
    Result = mnesia:activity(transaction, F),
    {reply, binary_utils:bin_join([<<"Pending:">>|Result], <<"\n">>), []}.
