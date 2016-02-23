-module(cowolg_flusher).

-export([init/2]).
-export([start_link/1]).

-record(state, {
    socket :: inet:socket()
}).

-spec init(pid(), atom()) -> no_return().
init(ParentPID, PName) ->
    case tcp_connect() of
        {ok, Socket} ->
            register(PName, self()),
            proc_lib:init_ack(ParentPID, {ok, self()}),
            loop(#state{socket = Socket});

        {error, Reason} ->
            log("Error : ~p~n", [Reason]),
            exit(Reason)
    end.

-spec start_link(atom()) -> {ok, pid()}.
start_link(PName) ->
    proc_lib:start_link(?MODULE, init, [self(), PName]).

%private --------------------------------------------------

tcp_connect() ->
    SockOpts = [binary, {packet, 0}],
    SockTimeOut = 1000,  % ms
    gen_tcp:connect(tcp_host(), tcp_port(), SockOpts, SockTimeOut).

tcp_host() ->
    cfg(tcp_host).

tcp_port() ->
    cfg(tcp_port).

cfg(Var) ->
    cowolg_cfg:get(flusher, Var).

loop(State) ->
    receive Msg ->
        {ok, State2} = handle_msg(Msg, State),
        loop(State2)
    end.

handle_msg({flush, Log}, State) ->
    Socket = State#state.socket,
    try
        erlang:port_command(Socket, prepare(Log))
    catch
        Error:Reason ->
            log("Error sending msg : ~s:~s", [Error, Reason])
    end,
    {ok, State};
handle_msg({inet_reply, _Socket, ok}, State) ->
    {ok, State};
handle_msg({inet_reply, _Socket, {error, Reason}}, State) ->
    log("inet_reply error: ~p~n", [Reason]),
    {ok, State};
handle_msg(Reason = tcp_closed, _State) ->
    exit(Reason).

prepare(Log) ->
    Log2 = cowolg_log:apply_filters(Log),
    Log3 = cowolg_log:to_json(Log2),
    cowolg_syslog:build_message(rfc5424, Log3).

log(Fmt, Args) ->
    error_logger:error_msg("[cowolg] " ++ Fmt, Args).
