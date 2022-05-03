-module(streamy_show).

-export([install/0, add_show/3, remove_show/3, exists/1]).

-record(streamy_show, {show_name :: binary(),
                       user :: binary(),
                       imdb_link :: binary()
                      }).

install() ->
    mnesia_utils:create(streamy_show, record_info(fields, streamy_show), []).

add_show(Args, _ApiPid, #{<<"author">> := #{<<"id">> := UserId}}) ->
    [IMDBLink|Rest] = lists:reverse(Args),
    ShowName = binary_utils:bin_join(lists:reverse(Rest), <<" ">>),
    Entry = #streamy_show{show_name=ShowName,
                          user=UserId,
                          imdb_link=IMDBLink
                         },
    mnesia_utils:write(Entry),
    {reply, <<"added ", ShowName/binary, " to database">>, []}.

remove_show(_Args, _ApiPid, #{<<"author">> := #{<<"id">> := _UserId}}) ->
    throw(not_implemented).

exists(ShowName) ->
    F = fun() ->
        case mnesia:read({streamy_show, ShowName}) of
            [] -> false;
            [_Entry] -> true
        end
    end,
    mnesia:activity(transaction, F).
