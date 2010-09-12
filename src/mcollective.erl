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

	io:format("~s~n", [yaml:encode(Request)]).
