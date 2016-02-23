-module(cowolg_worker_SUITE).

%% ct.
-export([all/0]).
-export([init_per_suite/1]).
-export([end_per_suite/1]).
-export([init_per_testcase/2]).
-export([end_per_testcase/2]).

% tests
-export([check_push/1]).

-include_lib("common_test/include/ct.hrl").

-define(M, cowolg_worker).
-define(APP, cowolg).

%% --------------------------------------------------------

all() -> [
    check_push
].

init_per_suite(Config) ->
    Config.

end_per_suite(Config) ->
    Config.

init_per_testcase(_TestCase, Config) ->
    {ok, _} = application:ensure_all_started(?APP),
    Config.

end_per_testcase(_TestCase, Config) ->
    ok = application:stop(?APP),
    Config.

% -----------------------------------------

check_push(_) ->
    StatusCode = 200,
    QS1 = [{<<"id">>, <<"1">>}],
    QS2 = [{<<"id">>, <<"1">>}],

    R1 = cowolg_test_helpers:cowboy_req([], QS1),
    R2 = cowolg_test_helpers:cowboy_req([], QS2),

    [] = gen_server:call(?M, {dump, bucket}),
    ?M:push(StatusCode, [], R1),
    ?M:push(StatusCode, [], R2),

    Expected = [
        cowolg_test_helpers:new_log(StatusCode, [], R1),
        cowolg_test_helpers:new_log(StatusCode, [], R2)
    ],
    Expected = gen_server:call(?M, {dump, bucket}).
