# AUTOR: Jorge Fernandez y Jorge Aznar
# NIAs: 721529 y 721556
# FICHERO: master.exs
# FECHA: 23 de noviembre de 2018
# TIEMPO: 13 horas 
# DESCRIPCION: codigo correspondiente al master a desarrollar en la practica 3

defmodule Master do
	def encontrar_amigos_rec_2_1(n, amigos, [],worker1,worker3, i, y) do
		encontrar_amigos_rec_13_2(n, amigos, worker1,worker3, i,[],y)
	end
	def encontrar_amigos_rec_2_1(n, amigos, worker2,worker1,worker3, i,y) do
	send(hd(worker2), {self(), y, :sumaListaDivisores})
							receive do
								{pid, x,n} -> cond do
														x == i && y != i && y > i ->
																  encontrar_amigos_rec_2(n, [{i, y}| amigos], worker2,worker1,worker3, i + 1)
														true			  -> 			
																  encontrar_amigos_rec_2(n, amigos, worker2,worker1,worker3, i + 1)
											   end
								{pid,:fallo} -> encontrar_amigos_rec_2_1(n,amigos,tl(worker2),worker1,worker3,i,y)
							end
	end
	def encontrar_amigos_rec_2(n, amigos, worker2,worker1,worker3, 1000001) do
	  lista = amigos
	end
	def encontrar_amigos_rec_2(n, amigos, [],worker1,worker3, i) do
		encontrar_amigos_rec_13(n, amigos, worker1,worker3, i)
	end
	def encontrar_amigos_rec_2(n, amigos, worker2,worker1,worker3, i) do
		send(hd(worker2), {self(), i, :sumaListaDivisores})
		receive do
			{pid, y, n}   ->IO.puts(i)
							send(hd(worker2), {self(), y, :sumaListaDivisores})
							receive do
									{pid, x,n} -> cond do
														   x == i && y != i && y > i ->
														   			encontrar_amigos_rec_2(n, [{i, y}| amigos], worker2,worker1,worker3, i + 1)
														   true			  -> 			
														   		    encontrar_amigos_rec_2(n, amigos, worker2,worker1,worker3, i + 1)
												   end        
									{pid,:fallo} -> encontrar_amigos_rec_2_1(n,amigos,tl(worker2),worker1,worker3,i,y)
							end
			{pid,:fallo} -> encontrar_amigos_rec_2(n,amigos,tl(worker2),worker1,worker3,i)
		end
	end

	def encontrar_amigos(n, amigos, worker2,worker1,worker3,tipo) do
		encontrar_amigos_rec_2(n, amigos, worker2,worker1,worker3, 1)
	end
	def encontrar_amigos_rec_13_3(n, amigos, worker1,[], i,y,x,y2) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13_3(n, amigos, worker1,worker3, i,y,x,y2) do
		send(hd(worker3), {self(), y2, :sumaLista})
		receive do
				{pid,x2,n}      ->cond do
												x2 == i && x != i && x > i ->
															encontrar_amigos_rec_13(n, [{i, x}| amigos], worker1,worker3, i + 1)
												true			  		-> 			
															encontrar_amigos_rec_13(n, amigos, worker1,worker3, i + 1)
										end
				{pid,:fallo}    ->encontrar_amigos_rec_13_3(n, amigos, worker1,tl(worker3), i,y,x,y2)
		end
	end
	def encontrar_amigos_rec_13_2(n, amigos, [],worker3, i,y,x) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13_2(n, amigos, worker1,[], i,y,x) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13_2(n, amigos, worker1,worker3, i,y,x) do
		send(hd(worker1), {self(), x, :listaDivisores})
											receive do
												{pid, y2,n}   ->	send(hd(worker3), {self(), y2, :sumaLista})
																	receive do
																		{pid,x2,n}      ->cond do
																								x2 == i && x != i && x > i ->
																											encontrar_amigos_rec_13(n, [{i, x}| amigos], worker1,worker3, i + 1)
																								true			  		-> 			
																											encontrar_amigos_rec_13(n, amigos, worker1,worker3, i + 1)
																							end
																		{pid,:fallo}    ->encontrar_amigos_rec_13_3(n, amigos, worker1,tl(worker3), i,y,x,y2)
																	end
												{pid,:fallo} ->encontrar_amigos_rec_13_2(n, amigos, tl(worker1),worker3, i,y,x)
											end
	end
	def encontrar_amigos_rec_13_1(n, amigos, [],worker3, i,y) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13_1(n, amigos, worker1,[], i,y) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13_1(n, amigos, worker1,worker3, i,y) do
		send(hd(worker3), {self(), y, :sumaLista})
							receive do
								{pid, x,n } -> send(hd(worker1), {self(), x, :listaDivisores})
												receive do
													{pid, y2,n}   ->	send(hd(worker3), {self(), y2, :sumaLista})
																		receive do
																			{pid,x2,n}      ->cond do
																									x2 == i && x != i && x > i ->
																										encontrar_amigos_rec_13(n, [{i, x}| amigos], worker1,worker3, i + 1)
																								true			  		-> 			
																										encontrar_amigos_rec_13(n, amigos, worker1,worker3, i + 1)
																								end
																			{pid,:fallo}    ->encontrar_amigos_rec_13_3(n, amigos, worker1,tl(worker3), i,y,x,y2)
																		end
													{pid,:fallo} ->encontrar_amigos_rec_13_2(n, amigos, tl(worker1),worker3, i,y,x)
												end
								{pid,:fallo} ->encontrar_amigos_rec_13_1(n, amigos, worker1,tl(worker3), i,y)
							end
	end
	def encontrar_amigos_rec_13(n, amigos,[],worker3,i) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13(n, amigos, worker1,[],i) do
		IO.puts("No quedan workers, me voy")
	end
	def encontrar_amigos_rec_13(n, amigos, worker1,worker3, 1000001) do
	  lista = amigos
	end
	def encontrar_amigos_rec_13(n, amigos, worker1,worker3, i) do
		send(hd(worker1), {self(), i, :listaDivisores})
		receive do
			{pid, y,n}   ->	IO.puts(i)
							send(hd(worker3), {self(), y, :sumaLista})
							receive do
								{pid, x,n} -> send(hd(worker1), {self(), x, :listaDivisores})
											  receive do
											  	{pid, y2,n}   ->	send(hd(worker3), {self(), y2, :sumaLista})
											  						receive do
											  							{pid,x2,n}      ->cond do
											  														x2 == i && x != i && x > i ->
											  																	encontrar_amigos_rec_13(n, [{i, x}| amigos], worker1,worker3, i + 1)
											  														true			  		-> 			
											  															encontrar_amigos_rec_13(n, amigos, worker1,worker3, i + 1)
											  											   end
											  							{pid,:fallo}    ->encontrar_amigos_rec_13_3(n, amigos, worker1,tl(worker3), i,y,x,y2)
											  						end
											  	{pid,:fallo} ->encontrar_amigos_rec_13_2(n, amigos, tl(worker1),worker3, i,y,x)
											  end
								{pid,:fallo} ->encontrar_amigos_rec_13_1(n, amigos, worker1,tl(worker3), i,y)
								end
			{pid,:fallo} -> encontrar_amigos_rec_13(n, amigos, tl(worker1),worker3, i)
		end
	end
end