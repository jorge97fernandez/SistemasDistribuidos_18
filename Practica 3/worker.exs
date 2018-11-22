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
		  rem(n,m) == 0  -> lista = [div(n,m)| lista]
							lista = [m | lista]
							listaDivisores(m - 1,n,lista)
		  true     		 ->	listaDivisores(m - 1,n,lista)
		end
	end
	
	def divisores(n,pid) do
	  lista= listaDivisores(trunc((:math.sqrt(n))+1),n,[])
	  send(pid,{self(),lista,n})
	end
	
	def sumaLista([],total,pid,n) do
	  send(pid,{self(),total,n})
	end
	
	def sumaLista(lista,total,pid,n) do
	  sumaLista(tl(lista),total+hd(lista),pid,n)
	end
	
	def sumaListaDivisores(n,pid) do
	  lista = listaDivisores(trunc((:math.sqrt(n))+1),n,[])
	  sumaLista(lista,0,pid,n)
	end
	
	def listaSumada(lista,pid) do
		sumaLista(lista,0,pid,lista)
	end
	def init do 
    case :random.uniform(100) do
      random when random > 80 -> :crash
      random when random > 50 -> :omission
      random when random > 25 -> :timing
      _ -> :no_fault
    end
  end  

  def loop do
    loopI(init())
  end
  def loopf() do
	loopI(:no_fault)
  end
  
  defp loopI(worker_type) do
    delay = case worker_type do
      :crash -> if :random.uniform(100) > 75, do: :infinity
      :timing -> :random.uniform(100)*1000
      _ ->  0
    end
    Process.sleep(delay)
    result = receive do
     {pid,i,:sumaListaDivisores} ->
             if (((worker_type == :omission) and (:random.uniform(100) < 75)) or (worker_type == :timing) or (worker_type==:no_fault)), do: sumaListaDivisores(i,pid)
	 {pid,i,:listaDivisores} ->
             if (((worker_type == :omission) and (:random.uniform(100) < 75)) or (worker_type == :timing) or (worker_type==:no_fault)), do: divisores(i,pid)
	 {pid,i,:sumaLista} ->
             if (((worker_type == :omission) and (:random.uniform(100) < 75)) or (worker_type == :timing) or (worker_type==:no_fault)), do: sumaLista(i,0,pid,i)
    end
    loopI(worker_type)
  end
	
	def worker() do
		receive do
			{pid,i,:sumaListaDivisores} -> sumaListaDivisores(i,pid)
			{pid,i,:listaDivisores}     -> divisores(i,pid)
			{pid,i,:sumaLista}          -> sumaLista(i,0,pid,i)
		end
		worker()
	end
	
end