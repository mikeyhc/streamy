%%%-------------------------------------------------------------------
%% @doc streamy public API
%% @end
%%%-------------------------------------------------------------------

-module(streamy_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Token = case os:getenv("DISCORD_TOKEN") of
                false -> throw({missing_env, "DISCORD_TOKEN"});
                V -> V
            end,
    streamy_request:install(),
    discordant:connect(Token),
    Routes = #{
        <<"request">> => #{call => {streamy_request, request, []},
                           args => ["anime name"],
                           help => "Request an anime be added to the database"
                          },
        <<"pending">> => #{call => {streamy_request, pending, []},
                           args => [],
                           help => "List all pending requests"
                          },
        <<"ping">> => #{call => {streamy, pong, []},
                        args => [],
                        help => "PONG!"
                       }
    },
    discordant:set_routes(Routes, []),
    streamy_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
