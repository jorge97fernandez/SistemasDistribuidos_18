# AUTOR: Jorge Fernandez y Jorge Aznar
# NIAs: 721529 y 721556
# FICHERO: chat.exs
# FECHA: 7 de noviembre de 2018
# TIEMPO: 9 horas 
# DESCRIPCION: codigo correspondiente al chat a desarrollar en la practica 2

defmodule Master do

	def encontrar_amigos_rec_2(n, amigos, worker, 1000001) do
	  lista = amigos
	end
	def encontrar_amigos_rec_2(n, amigos, worker, i) do
		send(worker, {self(), i, :sumaListaDivisores})
		receive do
			{pid, y}   ->	IO.puts(i)
							send(worker, {self(), y, :sumaListaDivisores})
							receive do
								{pid, x} -> cond do
											 x == i && y != i && y > i ->
																  encontrar_amigos_rec_2(n, [{i, y}| amigos], worker, i + 1)
										     true			  -> 			
																  encontrar_amigos_rec_2(n, amigos, worker, i + 1)
										   end
							end
		end
	end

	def encontrar_amigos(n, amigos, worker,tipo) do
	case tipo do
		:dos     ->encontrar_amigos_rec_2(n, amigos, worker, 1)
		:unotres ->encontrar_amigos_rec_13(n, amigos, worker, 1)
	end
	end	
	def encontrar_amigos_rec_13(n, amigos, worker, 1000001) do
	  lista = amigos
	end
	def encontrar_amigos_rec_13(n, amigos, worker, i) do
		send(worker, {self(), i, :listaDivisores})
		receive do
			{pid, y}   ->	IO.puts(i)
							send(worker, {self(), y, :sumaLista})
							receive do
								{pid, x} -> send(worker, {self(), x, :listaDivisores})
											receive do
												{pid, y2}   ->	send(worker, {self(), y2, :sumaLista})
												receive do
													{pid,x2}      ->cond do
																	x2 == i && x != i && x > i ->
																						encontrar_amigos_rec_13(n, [{i, x}| amigos], worker, i + 1)
																	true			  		-> 			
																				encontrar_amigos_rec_13(n, amigos, worker, i + 1)
																	end
												end
											end
							end
		end
	end
end

	