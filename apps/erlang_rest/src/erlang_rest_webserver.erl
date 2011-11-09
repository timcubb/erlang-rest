-module(erlang_rest_webserver).
-export([start_link/0, stop/0]).

% start misultin http server
start_link() ->
    misultin:start_link([{port, 8080}, {loop, fun(Req) -> handle_http(Req) end}]).

% stop misultin
stop() ->
    misultin:stop().

% callback function called on incoming http request
handle_http(Req) ->
    % dispatch to rest
    handle(Req:get(method), Req:resource([lowercase, urldecode]), Req).

% ---------------------------- \/ handle rest --------------------------------------------------------------

% handle a GET on /
handle('GET', [], Req) ->
    Req:ok([{"Content-Type", "text/plain"}], "Main home page.");

% handle a GET on /users
handle('GET', ["users"], Req) ->
    Req:ok([{"Content-Type", "text/plain"}], "Main users root.");

% handle a GET on /users/{username}
handle('GET', ["users", UserName], Req) ->
    Req:ok([{"Content-Type", "text/plain"}], "This is ~s's page.", [UserName]);

% handle a GET on /users/{username}/messages
handle('GET', ["users", UserName, "messages"], Req) ->
    Req:ok([{"Content-Type", "text/plain"}], "This is ~s's messages page.", [UserName]);

% handle the 404 page not found
handle(_, _, Req) ->
    Req:ok([{"Content-Type", "text/plain"}], "Page not found.").

% ---------------------------- /\ handle rest --------------------------------------------------------------
