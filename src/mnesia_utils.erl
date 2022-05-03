-module(mnesia_utils).
-include_lib("kernel/include/logger.hrl").

-export([create/3, write/1]).

create(Name, Fields, Overrides) ->
    Defaults = [{attributes, Fields},
                {disc_copies, [node()]}],
    Options = lists:keymerge(1, Overrides, Defaults),
    case lists:member(Name, mnesia:system_info(tables)) of
        true ->
            ?LOG_INFO("~p table already installed", [Name]),
            ok;
        false ->
            ?LOG_INFO("installing ~p table", [Name]),
            mnesia:create_table(Name, Options)
    end.

write(Entry) ->
    mnesia:activity(transaction, fun() -> mnesia:write(Entry) end).
