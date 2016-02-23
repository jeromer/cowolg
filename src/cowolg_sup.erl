-module(cowolg_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-include("cowolg.hrl").

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Flusher = cowolg_utils:flusher_child_specs(),
    Worker  = ?WORKER(cowolg_worker),

	{ok, {{one_for_one, 10, 5},
        Flusher ++ [Worker]
    }}.
