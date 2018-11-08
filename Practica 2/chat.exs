# AUTOR: Jorge Fernández y Jorge Aznar
# NIAs: 721529 y 721556
# FICHERO: chat.exs
# FECHA: 7 de noviembre de 2018
# TIEMPO: 9 horas 
# DESCRIPCI'ON: codigo correspondiente al chat a desarrollar en la practica 2

defmodule Chat do

	def mutex() do
		receive do
			{pid, :pido_mutex} -> send(pid, :mutex)
		end
		receive do
			{pid, :libero_mutex} -> mutex()
		end
	end
	
	def enviarMensajes(nodos, num, my_num, num, number,reply_server) do
		cond do
			num != my_num -> send(hd(nodos),{self(),number,reply_server,my_num,num})
			true 		  ->
		end
	end
	
	def enviarMensajes(nodos,num, my_num,i, number,reply_server) do
		cond do
			i == my_num -> enviarMensajes(tl(nodos),num,my_num, i+1,number,reply_server)
			i != my_num -> send(hd(nodos),{self(),number,reply_server,my_num,num}) 
						   enviarMensajes(tl(nodos), num, my_num, i+1,number,reply_server)
						   
		end
	end
	
	def enviarReply(nodos,num,my_num,num,replys) do
		cond do
			hd(replys) == 1 && num != my_num -> send(hd(nodos),:ok)
			true 						   	 ->
		end
	end
	
	def enviarReply(nodos,num,my_num,i,replys) do
		cond do
			hd(replys) == 1 && i != my_num -> send(hd(nodos),:ok)
			true 						   ->
		end
		enviarReply(tl(nodos),num, my_num, i+1,tl(replys))
	end
	
	def anyadirCola(database,her_number,1,reply_Deferred) do
		cond do
			her_number == 1 -> reply_Deferred =[1| reply_Deferred]
							   send(database,{reply_Deferred,:actualizaReply})
			true			-> reply_Deferred= [0| reply_Deferred]
							   send(database,{reply_Deferred,:actualizaReply})
		end
	end
	
	def anyadirCola(database,her_number,i,reply_Deferred) do
		cond do
			her_number == i -> reply_Deferred= [1| reply_Deferred]
							   anyadirCola(database,her_number,i-1,reply_Deferred)
			true 			-> 	reply_Deferred= [0| reply_Deferred]
								anyadirCola(database,her_number,i-1,reply_Deferred)
		end
	end
	
	def enviaMensaje(nodos,mensaje,total,num_propio,total) do
		send(hd(nodos),{mensaje,:mensaje})
	end
	
	def enviaMensaje(nodos,mensaje,total,num_propio,i) do
		send(hd(nodos),{mensaje,:mensaje})
		enviaMensaje(tl(nodos),mensaje,total,num_propio,i+1)
	end
	
	def shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje) do
		receive do
			{pid,:request_critical_section} -> requesting_Critical_Section_initial= 1
											   send(pid,{highest_secuence_number, n, me,reply_Deferred, :highest_number})
											   shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje)
			{pid,:reiniciar_Count} -> 		   outstanding_Reply_Count = n-1
											   shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje)
			{pid,:signal_critical_section}  -> requesting_Critical_Section_initial= 0
											   shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje)
			{pid,:replied}					-> outstanding_Reply_Count = outstanding_Reply_Count - 1
											   cond do
													outstanding_Reply_Count == 0 -> send(enviaMensaje,{self(),:reply_completa})
													true						 ->
											   end
											   shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje)
			{new_highest,:modifica}         -> highest_secuence_number = new_highest
											   shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje)
			{pid,:my_data}				    -> send(pid,{self(),requesting_Critical_Section_initial,our_SequenceNumber,me,reply_Deferred})
											   shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje)
			{pid,:my_highest}               -> send(pid,highest_secuence_number)
											   shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje)
			{numero,:actualiza}             -> our_SequenceNumber = numero
											   shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje)
			{replis,:actualizaReply}		-> reply_Deferred = replis
											   shared_database(me, n, our_SequenceNumber, highest_secuence_number, outstanding_Reply_Count, requesting_Critical_Section_initial, reply_Deferred,enviaMensaje)
		end
		
	end
	
	def enviar_mensaje(mutex,database,nodos,reply_server,reply_nodos,msj) do
		Process.sleep(1500)
		mensaje= msj
		send(mutex,{self(),:pido_mutex})
		receive do
			:mutex -> send(database,{self(),:request_critical_section})
		end
		receive do
			{my_highest_number,num,numeroPropio,replys,:highest_number} ->
																		number = my_highest_number + 1
																		send(database,{number,:actualiza})
																		send(mutex,{self(),:libero_mutex})
																		send(database,{self(),:reiniciar_Count})
																		enviarMensajes(nodos,num,numeroPropio,1,number,reply_server)
																		receive do
																			{pid,:reply_completa} ->send(database,{self(),:signal_critical_section})
																		end
																		enviaMensaje(reply_nodos,mensaje,num,numeroPropio,1)
																		enviarReply(nodos,num,numeroPropio,1,reply_nodos)
		end
		enviar_mensaje(mutex,database,nodos,reply_server,reply_nodos,msj)
	end
	
	def recibeRequest(mutex, database) do
		receive do
			{pid,her_sequence_number, her_replyserver,her_number,total}	->  send(database,{self(),:my_highest})
																			receive do
																			  highest_prev ->	cond do
																								  her_sequence_number > highest_prev -> send(database,{her_sequence_number,:modifica})
																								  true 							   	 -> send(database,{highest_prev,:modifica})
																								end
																			end
																			send(mutex,{self(),:pido_mutex})
																			  receive do
																			    :mutex -> send(database,{self(),:my_data})
																			  end
																			receive do
																			  {pid,me_requesting,my_sequence_number,my_number,reply_Deferred} ->  cond do
																																					  me_requesting ==1 && ((her_sequence_number > my_sequence_number) || (her_sequence_number == my_sequence_number && her_number > my_number)) -> defer_it =1
																																																																							  send(mutex,{self(),:libero_mutex})
																																																																					          anyadirCola(database,her_number,total,[])
																																					  true -> defer_it=0
																																						send(mutex,{self(),:libero_mutex})
																																						send(her_replyserver,:ok)
																																					end
																			end
		end
		recibeRequest(mutex, database)
	end
	
	def recibeReply(database) do
		receive do
			:ok 						-> 	send(database,{self(),:replied})
			{mensaje,:mensaje}          ->	IO.puts(mensaje)
			end
		recibeReply(database)
	end
	def creaProcesos(nodos,me,n,replis) do
		pid_mutex= spawn(Chat,:mutex,[])
		Process.register(pid_mutex,:mi_mutex)
		pid_database= spawn(Chat,:shared_database,[me,n,0,0,0,0,[0,0,0],{:envia,Node.self()}])
		Process.register( pid_database,:mi_database)
		pid_recibe_req= spawn(Chat,:recibeRequest,[{:mi_mutex,Node.self()},{:mi_database,Node.self()}])
		Process.register(pid_recibe_req,:request)
		pid_recibe_rep= spawn(Chat,:recibeReply,[{:mi_database,Node.self()}])
		Process.register(pid_recibe_rep,:reply)
		Process.register(self(),:envia)
		enviar_mensaje({:mi_mutex,Node.self()},{:mi_database,Node.self()},nodos,{:reply,Node.self()},replis,me)
	end
end
