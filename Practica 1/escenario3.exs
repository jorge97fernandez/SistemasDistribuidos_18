# AUTOR: Jorge Fernandez Muñoz y Jorge Aznar Lopez
# NIAs: 721529,721556
# FICHERO: escenario3.exs
# FECHA: 24 de septiembre de 2018
# TIEMPO: 1 hora
# DESCRIPCI'ON: codigo correspondiente al servidor/worker del escenario 3 de la practica 1

defmodule Perfectos do
  defp suma_divisores_propios(n, 1) do
    1
  end
  
  defp suma_divisores_propios(n, i) when i > 1 do
    if rem(n, i)==0, do: i + suma_divisores_propios(n, i - 1), else: suma_divisores_propios(n, i - 1)
  end
  
  def suma_divisores_propios(n) do
    suma_divisores_propios(n, n - 1)
  end
  
  def es_perfecto?(1) do
    false
  end
  
  def es_perfecto?(a) when a > 1 do
    suma_divisores_propios(a) == a
  end
 
  defp encuentra_perfectos({a, a}, queue) do
    if es_perfecto?(a), do: [a | queue], else: queue
  end
  defp encuentra_perfectos({a, b}, queue) when a != b do
    encuentra_perfectos({a, b - 1}, (if es_perfecto?(b), do: [b | queue], else: queue))
  end

  def encuentra_perfectos({a, b}) do
    encuentra_perfectos({a, b}, [])
  end 
  
  def thread_encuentra_perfectos(client_pid,{a,	b}) do
    time1 = :os.system_time(:millisecond)
    perfectos = encuentra_perfectos({a,b})
    time2 = :os.system_time(:millisecond)    
    send(client_pid, {time2 - time1, perfectos})
  end
  def concatena(a,b) do
    a++b
  end
  
  def servidor(lista,num,ultim) do
    receive do
      {pid, :perfectos} -> 	ultim=ultim+1
				ultim=rem(ultim,num)
				send(elem(lista,ultim), {pid,:trabaja})
      {pid, :perfectos_ht} ->	time1 = :os.system_time(:millisecond)
      				if :rand.uniform(100)>60, do: Process.sleep(round(:rand.uniform(100)/100 * 2000))
				perfectos = encuentra_perfectos({1, 10000})
				time2 = :os.system_time(:millisecond)			
				send(pid, {time2 - time1, perfectos})
	  {pid, :trabaja} ->	spawn(Perfectos,:thread_encuentra_perfectos,[pid,{1,1000}])
    end  
    servidor(lista,num,ultim)  
  end 
end

