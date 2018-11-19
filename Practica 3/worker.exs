# AUTOR: Jorge Fernández y Jorge Aznar
# NIAs: 721529 y 721556
# FICHERO: chat.exs
# FECHA: 7 de noviembre de 2018
# TIEMPO: 9 horas 
# DESCRIPCI'ON: codigo correspondiente al chat a desarrollar en la practica 2

defmodule Worker do
	def listadivisores(1,n,lista) do
		lista= [1|lista]
	end
	def listadivisores(m,n,lista) do
		cond do
		rem(n,m)==0  -> lista= [m|lista]
						listadivisores(m-1,n,lista)
		true     ->		listadivisores(m-1,n,lista)
		end
	end
	def divisores(n) do
		listadivisores(div(n,2),n,[n])
	end
	def sumaLista([],total) do
		cuentatotal=total
	end
	def sumaLista(lista,total) do
		total= total+ hd(lista)
		sumaLista(tl(lista),total)
	end
	def sumaListaDivisores(n) do
		lista= listadivisores(div(n,2),n,[n])
		sumaLista(lista,0)
	end
	
	def listaSumada(lista) do
		sumaLista(lista,0)
	end
end