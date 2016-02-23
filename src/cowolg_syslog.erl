-module(cowolg_syslog).

-export([build_message/2]).

build_message(rfc5424, Content) ->
    Local0 = "16",

    % XXX : this should be cached somehow
    {ok, HostName} = inet:gethostname(),

    io_lib:format("<~s>1 ~s ~s ~s ~s - - ~s~n", [
        Local0,
        utc_time_rfc3339(),
        HostName,
        <<"cowboy">>,
        pid_to_list(self()), % XXX : any better option here ?
        Content
    ]).

% private -------------------------------------------------

utc_time_rfc3339() ->
    UTCTime = localtime_utc(),
    {Date, Time} = format_time({utc, UTCTime}),
    list_to_binary(lists:flatten([Date,$T,Time])).

localtime_utc() ->
    Now = os:timestamp(),

    {_, _, Micro} = Now,
    {Date, {Hours, Minutes, Seconds}} = calendar:now_to_universal_time(Now),
    {Date, {Hours, Minutes, Seconds, Micro div 1000 rem 1000}}.

% from lager util
format_time({utc, {{Y, M, D}, {H, Mi, S, Ms}}}) ->
    {[integer_to_list(Y), $-, i2l(M), $-, i2l(D)],
     [i2l(H), $:, i2l(Mi), $:, i2l(S), $., i3l(Ms), $Z]}.

i2l(I) when I < 10  -> [$0, $0+I];
i2l(I)              -> integer_to_list(I).

i3l(I) when I < 100 -> [$0 | i2l(I)];
i3l(I)              -> integer_to_list(I).
