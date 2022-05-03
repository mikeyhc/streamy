-module(streamy_playlist).

-export([install/0, add_entry/3, remove_entry/3]).

-record(streamy_playlist_entry, {show_name :: binary(),
                                 user :: binary(),
                                 position :: pos_integer()
                                }).

install() ->
    mnesia_utils:create(streamy_playlist_entry,
                        record_info(fields, streamy_playlist_entry),
                        [{type, bag}]).

add_entry(ShowNameParts, _ApiPid, #{<<"author">> := #{<<"id">> := UserId}}) ->
    ShowName = binary_utils:bin_join(ShowNameParts, <<" ">>),
    case streamy_show:exists(ShowName) of
        false -> {reply, <<"show does not exist">>, []};
        true ->
            Entry = #streamy_playlist_entry{user=UserId,
                                            show_name=ShowName,
                                            position=next_position()
                                           },
            mnesia_utils:write(Entry),
            {reply, <<"added ", ShowName/binary, " to playlist">>, []}
    end.

remove_entry(_ShowNameParts, _ApiPid, _Data) ->
    throw(not_implemented).

next_position() ->
    F = fun(#streamy_playlist_entry{position=P}, Max) when P > Max -> P;
           (_Entry, Max) -> Max
        end,
    mnesia:activity(transaction,
                    fun() ->
                        mnesia:foldl(F, 1, streamy_playlist_entry) + 1
                    end).
