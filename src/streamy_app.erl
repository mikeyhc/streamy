%%%-------------------------------------------------------------------
%% @doc streamy public API
%% @end
%%%-------------------------------------------------------------------

-module(streamy_app).

-behaviour(application).

-export([start/2, stop/1]).

-define(TABLES, [streamy_request,
                 streamy_show,
                 streamy_playlist
                ]).

start(_StartType, _StartArgs) ->
    Token = case os:getenv("DISCORD_TOKEN") of
                false -> throw({missing_env, "DISCORD_TOKEN"});
                V -> V
            end,
    lists:foreach(fun(Name) -> apply(Name, install, []) end, ?TABLES),
    discordant:connect(Token),
    Routes = #{
        <<"request">> => #{call => {streamy_request, request, []},
                           args => ["show name"],
                           help => "Request an show be added to the database"
                          },
        <<"pending">> => #{call => {streamy_request, pending, []},
                           args => [],
                           help => "List all pending requests"
                          },
        <<"show-add">> => #{call => {streamy_show, add_show, []},
                            args => ["show name", "imdb link"],
                            help => "Add a show to the database",
                            authenticated => true
                           },
        <<"playlist-add">> => #{call => {streamy_playlist, add_entry, []},
                                args => ["show name"],
                                help => "Add a show to the playlist",
                                authenticated => true
                               }
    },
    discordant:set_routes(Routes, []),
    streamy_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
