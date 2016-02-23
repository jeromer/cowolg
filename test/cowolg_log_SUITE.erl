-module(cowolg_log_SUITE).

%% ct.
-export([all/0]).
-export([init_per_suite/1]).
-export([end_per_suite/1]).
-export([init_per_testcase/2]).
-export([end_per_testcase/2]).

% tests
-export([check_to_json/1]).

-include_lib("common_test/include/ct.hrl").

-define(M, cowolg_log).

%% --------------------------------------------------------

all() -> [
    check_to_json
].

init_per_suite(Config) ->
    Config.

end_per_suite(Config) ->
    Config.

init_per_testcase(_TestCase, Config) ->
    Config.

end_per_testcase(_TestCase, Config) ->
    Config.

% -----------------------------------------

check_to_json(_) ->
    RequestHeaders = [{<<"user-agent">>, <<"foo">>}],
    ResponseHeaders = [{<<"connection">>, <<"close">>}],
    QS = [{<<"a">>, <<"b">>}],
    StatusCode = 200,

    R = cowolg_test_helpers:cowboy_req(RequestHeaders, QS),
    L = cowolg_test_helpers:new_log(StatusCode, ResponseHeaders, R),

    {[
        {<<"status_code">>, 200},
        {<<"path">>, <<"/">>},
        {<<"headers">>, {[
            {<<"request">>, {[
                {<<"user-agent">>,<<"foo">>}
            ]}},
            {<<"response">>, {[
                {<<"connection">>,<<"close">>}
            ]}
        }]}},
        {<<"qs_vals">>, {[
            {<<"a">>,<<"b">>}
        ]}},
        {<<"method">>,<<"GET">>}
    ]} = jiffy:decode(?M:to_json(L)).
