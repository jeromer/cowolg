-module(cowolg).

-export([push/4]).

-spec push(cowboy:http_status(),
           cowboy:http_headers(),
           iodata(),
           cowboy:req()) -> cowboy:req().
push(StatusCode, Headers, _Body, Req) ->
    cowolg_worker:push(StatusCode, Headers, Req).
