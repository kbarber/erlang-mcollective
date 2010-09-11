-module('mcollective').

-export([test/0]).

test() ->
	{Msecs,Secs,_} = now(),
	Time = (Msecs * 1000000) + Secs,
	Callerid = <<"kbarber">>,
	Senderid = <<"obelisk.usr.bob.sh">>,
	Requestid = list_to_binary(
        string:to_lower(
            hex:bin_to_hexstr(
                crypto:md5(integer_to_list(Time))
            )
        )
    ),
	Body = yaml:encode(<<"ping">>),
	Msgtarget = <<"/topic/mcollective_dev.discovery.command">>,
	Hash = <<"asdf">>, % rsa base 64 sign of body

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
