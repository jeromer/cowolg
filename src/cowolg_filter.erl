-module(cowolg_filter).

-export([headers/1]).
-export([qs_vals/1]).

-ifdef(TEST).
-export([normalize/1]).
-export([filter/2]).
-endif.

-define(CFG(V), cowolg_cfg:get(filters, V)).

-spec headers(Hdrs::cowboy:http_headers()) -> Filtered when Filtered::cowboy:http_headers().
headers(Hdrs) ->
    filter(Hdrs, ?CFG(accepted_headers)).

-spec qs_vals(QSVals::cowboy_req:qs_vals()) -> Filtered when Filtered::cowboy_req:qs_vals().
qs_vals(QSVals) ->
    filter(QSVals, ?CFG(accepted_qs_vals)).

filter(Vals, Accepted) ->
    Accepted2 = normalize(Accepted),
    [{K, V} || {K, V} <- Vals, lists:member(K, Accepted2)].

-spec normalize(Values::list()) -> Normalized when Normalized::list().
normalize(Values) ->
    normalize(Values, []).

normalize([], Acc) ->
    lists:reverse(Acc);
normalize([H|T], Acc) when is_list(H)->
    H2 = list_to_binary(H),
    normalize([H2|T], Acc);
normalize([H|T], Acc) when is_binary(H)->
    normalize(T, [cowboy_bstr:to_lower(H)|Acc]).
