%% --------------------------
%% @copyright 2010 Bob.sh
%% @doc Mcollective Client API
%%
%% @end
%% --------------------------
-module('mcollective').

-export([test/0]).

test() ->
    % Generate current time (epoch seconds)
	{Msecs,Secs,_} = now(),
	Time = (Msecs * 1000000) + Secs,

    % Calling identification
	Callerid = <<"cert=kbarber">>,
	Senderid = <<"obelisk.usr.bob.sh">>,

    % Generate a request id
	Requestid = list_to_binary(
        string:to_lower(
            mcollective_hex:bin_to_hexstr(
                crypto:md5(integer_to_list(Time))
            )
        )
    ),

    % Body of message, encoded as yaml
	Body = yaml:encode(<<"ping">>),

    % Msg target
	Msgtarget = <<"/topic/mcollective_dev.discovery.command">>,

    % Generate a decent hash from the body
    {ok,[Entry]} = public_key:pem_to_der("/home/kbarber/.ssh/kbarber.pem"),
    {ok, PrivKey} = public_key:decode_private_key(Entry),
    HashRaw = public_key:sign(Body, PrivKey),
    Hash = base64:encode(HashRaw),

    % Start to create the YAML data structure
    Request = [
        {<<":msgtime">>, Time},
        {<<":filter">>, [
            { <<"identity">>, [] },
            { <<"fact">>, [] },
            { <<"agent">>, [] },
            { <<"cf_class">>, [] }
         ]},
        {<<":requestid">>, Requestid},
        {<<":callerid">>, Callerid},
        {<<":senderid">>, Senderid},
        {<<":body">>, Body},
        {<<":msgtarget">>, Msgtarget},
        {<<":hash">>, Hash}
    ],

    % Convert to YAML text
    Yamlmsg = io_lib:format("~s", [yaml:encode(Request)]),
    io:format("Message is: ~n~s~n", [Yamlmsg]),

    % Connect to STOMP
    Conn = stomp:connect("localhost", 61613, "", ""),
    
    % Subscribe to reply
    io:format("Subscribing to reply channel~n"),
    stomp:subscribe("/topic/mcollective_dev.discovery.reply", Conn),
    
    % Send message
    io:format("Sending message~n"),
    stomp:send(Conn, "/topic/mcollective_dev.discovery.command", [], Yamlmsg),

    % Get response
    io:format("Getting message~n"),
    Msgs = stomp:get_messagesq(Conn),
    io:format("Got messages: ~n~p~n", Msgs),

    % Disconnect
    io:format("Disconnecting~n"),
    stomp:disconnect(Conn),

    ok.
