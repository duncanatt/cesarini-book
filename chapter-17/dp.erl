-module(dp).
-compile(export_all).

process_msg() ->
    case ets:first(msgQ) of
	'$end_of_table' ->
	    ok;
	Key ->
	    case ets:lookup(msgQ, Key) of
		[{_, {event, Sender, Msg}}] ->
		    event(Sender, Msg);
		[{_, {ping, Sender}}] ->
		    ping(Sender)
	    end,
	    ets:delete(msgQ, Key),
	    Key
    end.

event(_,_) -> ok.
ping(_) -> ok.

fill() ->
    catch ets:new(msgQ, [named_table, ordered_set]),
    dp:handle_msg(<<2,3,0,2,0>>).

handle_msg(<<MsgId, MsgType, Sender:16, MsgLen, Msg:MsgLen/binary>>) -> 
	Element = handle(MsgType, Sender, Msg),
	ets:insert(msgQ, {MsgId, Element}).


handle(1, Sender, Msg) -> {event, Sender, Msg}; 
handle(2, Sender, _Msg) -> {ping, Sender}; 
handle(_Id, _Sender, _Msg) -> {error, unknown_msg}.