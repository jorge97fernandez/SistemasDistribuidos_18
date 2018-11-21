# AUTOR: Jorge Fernandez y Jorge Aznar
# NIAs: 721529 y 721556
# FICHERO: chat.exs
# FECHA: 7 de noviembre de 2018
# TIEMPO: 9 horas 
# DESCRIPCION: codigo correspondiente al chat a desarrollar en la practica 2

defmodule Master do
	def encontrar_amigos_rec_2_1(n, amigos, [],worker13, i, y) do
		encontrar_amigos_rec_13_2(n, amigos, worker, i,[],y)
	end
	def encontrar_amigos_rec_2_1(n, amigos, worker2,worker13, i,y) do
	send(hd(worker2), {self(), y, :sumaListaDivisores})
							receive do
								{pid, x} -> cond do
											 x == i && y != i && y > i ->
																  encontrar_amigos_rec_2(n, [{i, y}| amigos], worker, i + 1)
										     true			  -> 			
																  encontrar_amigos_rec_2(n, amigos, worker, i + 1)
										   end
								after 1000 -> encontrar_amigos_rec_2_1(n,amigos,tl(worker2),worker13,i,y)
							end
	end
	def encontrar_amigos_rec_2(n, amigos, worker2,worker13, 1000001) do
	  lista = amigos
	end
	def encontrar_amigos_rec_2(n, amigos, [],worker13, i) do
		encontrar_amigos_rec_13(n, amigos, worker13, i) do
	end
	def encontrar_amigos_rec_2(n, amigos, worker2,worker13, i) do
		send(hd(worker2), {self(), i, :sumaListaDivisores})
		receive do
			{pid, y}   ->	IO.puts(i)
							send(hd(worker2), {self(), y, :sumaListaDivisores})
							receive do
								{pid, x} -> cond do
											 x == i && y != i && y > i ->
																  encontrar_amigos_rec_2(n, [{i, y}| amigos], worker, i + 1)
										     true			  -> 			
																  encontrar_amigos_rec_2(n, amigos, worker, i + 1)
										   end
								after 1000 -> encontrar_amigos_rec_2_1(n,amigos,tl(worker2),worker13,i,y)
							end
			after 1000 -> encontrar_amigos_rec_2(n,amigos,tl(worker2),worker13,i)
		end
	end

	def encontrar_amigos(n, amigos, worker2,worker13,tipo) do
		encontrar_amigos_rec_2(n, amigos, worker2,worker13, 1)
	end
	end
	def encontrar_amigos_rec_13_3(n, amigos, [], i,y,x,y2) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13_3(n, amigos, worker, i,y,x,y2) do
		send(hd(worker), {self(), y2, :sumaLista})
																receive do
																	{pid,x2}      ->cond do
																					x2 == i && x != i && x > i ->
																									encontrar_amigos_rec_13(n, [{i, x}| amigos], worker, i + 1)
																					true			  		-> 			
																					encontrar_amigos_rec_13(n, amigos, worker, i + 1)
																					end
																	after 1000    ->encontrar_amigos_rec_13_3(n, amigos, tl(worker), i,y,x,y2)
																end
	end
	def encontrar_amigos_rec_13_2(n, amigos, worker, i,y,x) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13_2(n, amigos, worker, i,y,x) do
		send(hd(worker), {self(), x, :listaDivisores})
											receive do
												{pid, y2}   ->	send(hd(worker), {self(), y2, :sumaLista})
																receive do
																	{pid,x2}      ->cond do
																					x2 == i && x != i && x > i ->
																									encontrar_amigos_rec_13(n, [{i, x}| amigos], worker, i + 1)
																					true			  		-> 			
																					encontrar_amigos_rec_13(n, amigos, worker, i + 1)
																					end
																	after 1000    ->encontrar_amigos_rec_13_3(n, amigos, tl(worker), i,y,x,y2)
																end
												after 1000 ->encontrar_amigos_rec_13_2(n, amigos, tl(worker), i,y,x)
											end
	end
	def encontrar_amigos_rec_13_1(n, amigos, [], i,y) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13_1(n, amigos, worker, i,y) do
		send(hd(worker), {self(), y, :sumaLista})
							receive do
								{pid, x} -> send(hd(worker), {self(), x, :listaDivisores})
											receive do
												{pid, y2}   ->	send(hd(worker), {self(), y2, :sumaLista})
																receive do
																	{pid,x2}      ->cond do
																					x2 == i && x != i && x > i ->
																									encontrar_amigos_rec_13(n, [{i, x}| amigos], worker, i + 1)
																					true			  		-> 			
																					encontrar_amigos_rec_13(n, amigos, worker, i + 1)
																					end
																	after 1000    ->encontrar_amigos_rec_13_3(n, amigos, tl(worker), i,y,x,y2)
																end
												after 1000 ->encontrar_amigos_rec_13_2(n, amigos, tl(worker), i,y,x)
											end
								after 1000 ->encontrar_amigos_rec_13_1(n, amigos, tl(worker), i,y)
							end
	end
	def encontrar_amigos_rec_13(n, amigos, [], i) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13(n, amigos, worker, 1000001) do
	  lista = amigos
	end
	def encontrar_amigos_rec_13(n, amigos, worker, i) do
		send(hd(worker), {self(), i, :listaDivisores})
		receive do
			{pid, y}   ->	IO.puts(i)
							send(hd(worker), {self(), y, :sumaLista})
							receive do
								{pid, x} -> send(hd(worker), {self(), x, :listaDivisores})
											receive do
												{pid, y2}   ->	send(hd(worker), {self(), y2, :sumaLista})
																receive do
																	{pid,x2}      ->cond do
																					x2 == i && x != i && x > i ->
																									encontrar_amigos_rec_13(n, [{i, x}| amigos], worker, i + 1)
																					true			  		-> 			
																					encontrar_amigos_rec_13(n, amigos, worker, i + 1)
																					end
																	after 1000    ->encontrar_amigos_rec_13_3(n, amigos, tl(worker), i,y,x,y2)
																end
												after 1000 ->encontrar_amigos_rec_13_2(n, amigos, tl(worker), i,y,x)
											end
								after 1000 ->encontrar_amigos_rec_13_1(n, amigos, tl(worker), i,y)
							end
			after 1000 -> encontrar_amigos_rec_13(n, amigos, tl(worker), i)
		end
	end
end