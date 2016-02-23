-module(cowolg_worker).
-behaviour(gen_server).

% API.
-export([start_link/0]).
-export([push/3]).

% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-ifdef(TEST).
-export([bucket_size/0]).
-endif.

-record(state, {
    bucket = {0, []} % {Size, Values}
}).
-type state() ::#state{}.

% API -----------------------------------------------------

-spec start_link() -> {ok, pid()}.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

-spec push(S::cowboy:http_status(),
           Hdrs::cowboy:http_headers(),
           Req::cowboy:req()) -> Req when Req::cowboy:req().
push(S, Hdrs, Req) ->
    {Log, Req1} = cowolg_log:new(S, Hdrs, Req),
    gen_server:cast(?MODULE, {push, Log}),
    Req1.

% gen_server ----------------------------------------------

init([]) ->
	{ok, #state{}}.

handle_call({dump, bucket}, _From, State) ->
    {_Size, Values} = State#state.bucket,
    {reply, lists:reverse(Values), State};
handle_call(_Request, _From, State) ->
	{reply, ignored, State}.

handle_cast({push, Log}, State) ->
	{noreply, push(Log, State)};
handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

% private -------------------------------------------------

-spec push(cowolg_log:log(), state()) -> state().
push(Log, State) ->
    State2 = maybe_flush_bucket(State),
    {Size, Values} = State2#state.bucket,
    State2#state{
        bucket = {Size + 1, [Log|Values]}
    }.

-spec maybe_flush_bucket(S::state()) -> state().
maybe_flush_bucket(S) ->
    {Size, Values} = S#state.bucket,

    case Size >= bucket_size() of
        true  ->
            _ = archive_bucket(Values),
            S#state{bucket = {0, []}};

        false ->
            S
    end.

bucket_size() ->
    cowolg_cfg:get(worker, bucket_size).

archive_bucket(Logs) ->
    [flush(L) || L <- lists:reverse(Logs)].

flush(L) ->
    Pid = cowolg_utils:random_flusher(),
    flush(Pid, L).

flush(Pid, Log) ->
    try
        Pid ! {flush, Log},
        ok
    catch
        error:badarg ->
            ok
    end.
