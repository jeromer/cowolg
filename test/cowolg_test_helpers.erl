-module(cowolg_test_helpers).

-export([cowboy_req/2]).
-export([new_log/3]).

cowboy_req(Headers, QS) ->
    Host         = undefined,
    Method       = <<"GET">>,
    Peer         = undefined,
    Version      = undefined,
    Port         = undefined,
    Socket       = undefined,
    Transport    = undefined,
    Buffer       = undefined,
    Compress     = undefined,
    OnResponse   = undefined,
    CanKeepalive = false,

    cowboy_req:new(Socket, Transport, Peer,
                   Method, <<"/">>, cow_qs:qs(QS),
                   Version, Headers, Host,
                   Port, Buffer, CanKeepalive,
                   Compress, OnResponse).

new_log(StatusCode, ResponseHeaders, Req) ->
    {L, _} = cowolg_log:new(StatusCode, ResponseHeaders, Req),
    L.
