# AUTOR: Jorge Fernández y Jorge Aznar
# NIAs: 721529 y 721556
# FICHERO: chat.exs
# FECHA: 23 de noviembre de 2018
# TIEMPO: 13 horas 
# DESCRIPCION: codigo correspondiente al worker a desarrollar en la practica 3

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
	
	def pedir_calculo(n,mensaje,pid_master,pid_worker,timeout,retry) when retry <5 do
		send(pid_worker,{self(),n,mensaje})
		receive do
			{pid,total,num} -> if ( num ==n )do
							   send(pid_master,{self(),total,num})
							   else
							   pedir_calculo(n,mensaje,pid_master,pid_worker,timeout*2,retry+1)
							   end
			after timeout   -> pedir_calculo(n,mensaje,pid_master,pid_worker,timeout*2,retry+1)
		end
	end
	def pedir_calculo(n,mensaje,pid_master,pid_worker,timeout,retry) when retry ==5 do
		send(pid_master,{self(),:fallo})
	end
	def proxy_worker(pid_worker) do
		receive do
			{pid,i,calculo} -> pedir_calculo(i,calculo,pid,pid_worker,100,0)
		end
		proxy_worker(pid_worker)
	end
	def iniciar_worker do
		pid_worker=spawn(Worker,:loop,[])
		proxy_worker(pid_worker)
	end
	def iniciar_worker_no_fault do
		pid_worker=spawn(Worker,:loopf,[])
		proxy_worker(pid_worker)
	end
	
end