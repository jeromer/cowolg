-module(cowolg_filter_SUITE).

%% ct.
-export([all/0]).
-export([init_per_suite/1]).
-export([end_per_suite/1]).
-export([init_per_testcase/2]).
-export([end_per_testcase/2]).

% tests
-export([check_normalize/1]).
-export([check_filter/1]).

-include_lib("common_test/include/ct.hrl").

-define(M, cowolg_filter).

%% --------------------------------------------------------

all() -> [
    check_normalize,
    check_filter
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

check_normalize(_) ->
    Expected = [
        <<"list">>,
        <<"uppercase">>,
        <<"binary">>,
        <<"lowercase">>,
        <<"lowercasebinary">>
    ],

    Expected = ?M:normalize([
        "list",
        "UPPERCASE",
        <<"binary">>,
        "lowercase",
        <<"lowercasebinary">>
    ]).

check_filter(_) ->
    Expected = [{<<"a">>, x}],
    Accepted = ["a"],
    Headers = Expected ++ [{<<"b">>, x}],

    Expected = ?M:filter(Headers, Accepted).
