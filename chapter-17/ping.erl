-module (ping).
-export ([start/0, send/1, loop/0, other_tracer/0]).

% Starts the loop function in a different process.
start() -> spawn_link(ping, loop, []).

% test() -> tl().
other_tracer() ->spawn(fun() -> tracer_loop() end).
% tl () -> tl().
tracer_loop() ->
	receive
		Any -> io:format("Received msg: ~p~n", [Any]),
		tracer_loop()
	end.

% Sends a ping message to the specified process.
send(Pid) ->
	Pid ! {self(), ping},
	receive
		pong -> pong
	after 2000 ->
		no_reply_after_2000
	end. 

% The main process loop which waits for a ping message,
% after which it tries to spawn an non-existent function.
loop() ->
	% io:format("Started main loop"),
	receive
		{Pid, ping} ->
			io:format("Received message from PID: ~p~n", [Pid]),
			spawn(crash, does_not_exist, []),
			% link(spawn(fun() -> 1+1 end)),
			Pid ! pong,
			loop();
		Any -> 
			io:format("===== Probs: ~p~n", [Any]),
			Any
	end.

% HandlerFun =
% 	fun({trace, Pid, gc_start, Start}, _) ->
% 		Start;
% 	({trace, Pid, gc_end, End}, Start) ->
% 		{_, {_,OHS}} = lists:keysearch(old_heap_size, 1, Start), 
% 		{_, {_,OHE}} = lists:keysearch(old_heap_size, 1, End), 
% 		io:format("Old heap size delta after gc:~w~n",[OHS-OHE]), 
% 		{_, {_,HS}} = lists:keysearch(heap_size, 1, Start),
% 		{_, {_,HE}} = lists:keysearch(heap_size, 1, End),
% 		io:format("Heap size delta after gc:~w~n",[HS-HE]) 
% 	end.
% DbgFun = 
% 	fun({trace, _Pid, _event, _data, Msg}, _Acc) -> 
% 		io:format("~s~n",[binary_to_list(Msg)])
% 	end.

% DbgFun = 
% 	fun({trace, _Pid, _event, _data, Msg}, _Acc) -> 
% 		io:format("~p~n", [Msg])
% 	end.