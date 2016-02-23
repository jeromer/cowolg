# cowolg
Access logs for cowboy.

# Description
This OTP application provides a [onresponse fun](http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy/index.html#onresponse_fun) for building access logs and sending them using syslog via TCP.
The example use case is the following:

    +----------------+                      +-------------------+
    | Your webserver |   ------ TCP ------> | Rsyslog/Syslog NG |
    +----------------+                      +-------------------+

# Installation

Add the library to your `rebar.config` or your `Makefile` (if you use `erlang.mk`) and compile it.
Then add it to your `.app.src` like this:

    {application, junk, [
        % [...]
        {applications, [
            kernel,
            stdlib,
            cowboy,
            cowolg
        ]},
        % [...]
    ]}.

In your cowboy router declare a [onresponse fun](http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy/index.html#onresponse_fun) like this:

    % [...]

    {ok, _} = cowboy:start_http(http, 1, [{port, 8000}], [
        {env, [{dispatch, Routes}]},
        {onresponse, fun cowolg:push/4}
    ]),

# Configuration

Cowolg support the following configuration:

        {filters, [
            {accepted_headers, []},
            {accepted_qs_vals, []}
        ]},

        {worker, [
            {bucket_size, 100}
        ]},

        {flusher, [
            {tcp_host, "localhost"},
            {tcp_port, 1234}
        ]}

Cowolg will filter any request and response headers which are not listed in `filters/acccepter_headers` before sending logs.
The same behaviour is applied for query string arguments, vie `filters/accepted_qs_vals`.
`bucket_size` control the in memory buffer size the worker process must be before flushing logs.
`flusher/tcp_host|tcp_port` control the tcp host and port flusher process must connect to.
The TCP server must be up and running before starting cowolg.
