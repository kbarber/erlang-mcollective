%% --------------------------
%% @copyright 2010 Bob.sh
%% @doc Primary entry point for tests.
%%
%% @end
%% --------------------------
-module(mcollective_tests).
-export([start/0]).

start() ->
    error_logger:tty(false),
    eunit:test(mcollective_hex,[verbose]),
    halt().
