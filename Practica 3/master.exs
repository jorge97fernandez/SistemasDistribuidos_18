# AUTOR: Jorge Fernandez y Jorge Aznar
# NIAs: 721529 y 721556
# FICHERO: chat.exs
# FECHA: 7 de noviembre de 2018
# TIEMPO: 9 horas 
# DESCRIPCION: codigo correspondiente al chat a desarrollar en la practica 2

defmodule Master do

	def encontrar_amigos_rec(n, amigos, worker, 1000001) do
	  lista = amigos
	end
	def encontrar_amigos_rec(n, amigos, worker, i) do
		send(worker, {self(), i, :sumaListaDivisores})
		receive do
			{pid, y}   ->	send(worker, {self(), y, :sumaListaDivisores})
							receive do
								{pid, x} -> cond do
											 x == i && y != i ->
																  encontrar_amigos_rec(n, [{i, y}| amigos], worker, i + 1)
										     true			  -> 			
																  encontrar_amigos_rec(n, amigos, worker, i + 1)
										   end
							end
		end
	end

	def encontrar_amigos(n, amigos, worker) do
	  encontrar_amigos_rec(n, amigos, worker, 1)
	end	
end

	