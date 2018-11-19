# AUTOR: Jorge Fernández y Jorge Aznar
# NIAs: 721529 y 721556
# FICHERO: chat.exs
# FECHA: 7 de noviembre de 2018
# TIEMPO: 9 horas 
# DESCRIPCION: codigo correspondiente al chat a desarrollar en la practica 2

defmodule Worker do

	def listaDivisores(1,n,lista) do
		lista = [1 | lista]
	end
	
	def listaDivisores(m,n,lista) do
		cond do
		  rem(n,m) == 0  -> lista = [m | lista]
							listaDivisores(m - 1,n,lista)
		  true     		 ->	listaDivisores(m - 1,n,lista)
		end
	end
	
	def divisores(n) do
	  listaDivisores(:math.sqrt(n) + 1,n,[])
	end
	
	def sumaLista([],total,pid) do
	  cuentaTotal = total
	  send(pid,{self,cuentaTotal})
	end
	
	def sumaLista(lista,total,pid) do
	  total= total + hd(lista)
	  sumaLista(tl(lista),total,pid)
	end
	
	def sumaListaDivisores(n,pid) do
	  lista = listaDivisores(:math.sqrt(n) + 1,n,[])
	  sumaLista(lista,0,pid)
	end
	
	def listaSumada(lista) do
		sumaLista(lista,0)
	end
	
	def worker() do
		receive do
			{pid,i,:sumaListaDivisores} -> sumaListaDivisores(i,pid)
		end
		worker()
end