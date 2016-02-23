-module(cowolg_utils).

-export([flusher_child_specs/0]).
-export([random_flusher/0]).

-include("cowolg.hrl").

flusher_child_specs() ->
    flusher_child_specs(flusher_pool_size(), []).

-spec random_flusher() -> pid().
random_flusher() ->
    S = flusher_pool_size(),
    Random = erlang:phash2({self(), os:timestamp()}, S) + 1,
    flusher_name(Random).

% private -------------------------------------------------

flusher_pool_size() ->
    5.

flusher_child_specs(0, Acc) ->
    Acc;
flusher_child_specs(I, Acc) ->
    Mod = cowolg_flusher,
    Name = flusher_name(I),
    Acc2 = [?WORKER(Name, Mod, [Name])|Acc],
    flusher_child_specs(I - 1, Acc2).

flusher_name(1) -> cowolg_flusher_1;
flusher_name(2) -> cowolg_flusher_2;
flusher_name(3) -> cowolg_flusher_3;
flusher_name(4) -> cowolg_flusher_4;
flusher_name(5) -> cowolg_flusher_5.
