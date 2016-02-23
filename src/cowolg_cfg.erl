-module(cowolg_cfg).

-export([get/2]).

get(Group, Var) ->
    {ok, Values} = application:get_env(cowolg, Group),
    {Var, Value} = proplists:lookup(Var, Values),
    Value.
