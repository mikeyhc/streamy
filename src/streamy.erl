-module(streamy).

-export([pong/3]).

pong(_Args, _ApiPid, _Data) ->
    {reply, <<"pong">>, []}.
