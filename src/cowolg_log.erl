-module(cowolg_log).

-export([new/3]).
-export([apply_filters/1]).
-export([to_json/1]).

-record(log, {
    status_code,
    method = <<>>,
    path = <<>>,
    qs_vals = [],
    headers = [
        {request, []},
        {response, []}
    ]
}).

-type headers() :: [{request, cowboy:http_headers()} | {response, cowboy:http_headers()}].
-export_type([headers/0]).

-type log() :: #log{}.
-export_type([log/0]).

-spec new(cowboy:http_status(), headers(), cowboy_req:req()) -> {log(), cowboy_req:req()}.
new(StatusCode, ResponseHeaders, Req) ->
    {QSVals, Req1}     = cowboy_req:qs_vals(Req),
    {ReqHeaders, Req2} = cowboy_req:headers(Req1),
    {Path, Req3}       = cowboy_req:path(Req2),
    {Method, Req4}     = cowboy_req:method(Req3),

    L = #log{
        status_code = StatusCode,
        method = Method,
        path = Path,
        qs_vals = QSVals,
        headers = [
            {request, ReqHeaders},
            {response, ResponseHeaders}
        ]
    },

    {L, Req4}.

-spec apply_filters(log()) -> log().
apply_filters(L) ->
    [{request, RequestHeaders}, {response, ResponseHeaders}] = get(headers, L),
    QSVals = get(qs_vals, L),
    M = cowolg_filter,

    L#log{
        qs_vals = M:qs_vals(QSVals),
        headers = [
            {request, M:headers(RequestHeaders)},
            {response, M:headers(ResponseHeaders)}
        ]
    }.

-spec to_json(log()) -> term().
to_json(L) ->
    [
        {request, RequestHeaders},
        {response, ResponseHeaders}
    ] = get(headers, L),

    try
        jiffy:encode({[
            {<<"status_code">>, get(status_code, L)},
            {<<"path">>, get(path, L)},
            {<<"headers">>, {[
                {<<"request">>, {RequestHeaders}},
                {<<"response">>, {ResponseHeaders}}
            ]}},
            {<<"qs_vals">>, {get(qs_vals, L)}},
            {<<"method">>, get(method, L)}
            ]}, [force_utf8]
        )
    catch
        _:E -> {error, E}
    end.

% private -------------------------------------------------

get(status_code, L) ->
    L#log.status_code;
get(path, L) ->
    L#log.path;
get(headers, L) ->
    L#log.headers;
get(qs_vals, L) ->
    L#log.qs_vals;
get(method, L) ->
    L#log.method.
