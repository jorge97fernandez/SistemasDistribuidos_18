Code.require_file("#{__DIR__}/cliente_gv.exs")

defmodule ServidorSA do
    
    # estado del servidor            
    defstruct   bd: %{}


    @intervalo_latido 50


    @doc """
        Obtener el hash de un string Elixir
            - Necesario pasar, previamente,  a formato string Erlang
         - Devuelve entero
    """
    def hash(string_concatenado) do
        String.to_charlist(string_concatenado) |> :erlang.phash2
    end

    @doc """
        Poner en marcha el servidor para gestión de vistas
        Devolver atomo que referencia al nuevo nodo Elixir
    """
    @spec startNodo(String.t, String.t) :: node
    def startNodo(nombre, maquina) do
                                         # fichero en curso
        NodoRemoto.start(nombre, maquina, __ENV__.file)
    end

    @doc """
        Poner en marcha servicio trás esperar al pleno funcionamiento del nodo
    """
    @spec startService(node, node) :: pid
    def startService(nodoSA, nodo_servidor_gv) do
        NodoRemoto.esperaNodoOperativo(nodoSA, __MODULE__)
        
        # Poner en marcha el código del gestor de vistas
        Node.spawn(nodoSA, __MODULE__, :init_sa, [nodo_servidor_gv])
   end

    #------------------- Funciones privadas -----------------------------

    def init_sa(nodo_servidor_gv) do
        Process.register(self(), :servidor_sa)
        # Process.register(self(), :cliente_gv)
 

    #------------- VUESTRO CODIGO DE INICIALIZACION AQUI..........

		server= %ServidorSA{}
		Map.new(server.bd)
		spawn(fn -> primerLatido(nodo_servidor_gv) end)
         # Poner estado inicial
        bucle_recepcion_principal(server,nodo_servidor_gv) 
    end


    defp bucle_recepcion_principal(server,nodo_servidor_gv) do
        receive do

                    # Solicitudes de lectura y escritura
                    # de clientes del servicio alm.
		  {:escribe_generico, {clave, nuevo_valor, con_hash}, pid} ->
				cond do
					con_hash == false ->
						{vista,booleano} = ClienteGV.obten_vista(nodo_servidor_gv)
						send({:servidor_sa,vista.copia},{:actualiza_copia,{clave, 							nuevo_valor, con_hash},Node.self()})
						receive do
						{:ok,nuevovalor} ->
						bd_nueva = escritura(server,clave,nuevo_valor)
						server = %{server| bd: bd_nueva}
						send({:cliente_sa,pid}, {:resultado,nuevo_valor})
						bucle_recepcion_principal(server,nodo_servidor_gv)
				end
				end
		  {:lee, clave, pid}  -> 
						res = Map.get(server.bd,clave)
						
						cond do
						  res == nil -> send({:cliente_sa,pid}, {:resultado,""})
						  true       -> send({:cliente_sa,pid}, {:resultado,res})
						end
						bucle_recepcion_principal(server,nodo_servidor_gv)
                  #{op, param, nodo_origen}  ->
		  {:actualiza_copia,{clave,nuevo_valor, con_hash},pid} ->
					cond do
					con_hash == false ->
						bd_nueva = escritura(server,clave,nuevo_valor)
						server = %{server| bd: bd_nueva}
						send({:servidor_sa,pid}, {:ok,nuevo_valor})
						#send({:servidor_sa,pid},{:actualiza_copia,{clave, 							nuevo_valor, con_hash},self()})
						bucle_recepcion_principal(server,nodo_servidor_gv)
				end
		{:envia_copia,nodo} -> 
					send({:servidor_sa,nodo},{:toma_copia,server.bd,Node.self()})
					bucle_recepcion_principal(server,nodo_servidor_gv)
		{:toma_copia,nuevabd,pid} ->
				IO.puts("Recibo copia")
				server = %{server| bd: nuevabd}
				bucle_recepcion_principal(server,nodo_servidor_gv)
							
		true  -> IO.puts("Mensaje ha llegado, pero no correcto")


                        # ----------------- vuestro código


                  # --------------- OTROS MENSAJES QUE NECESITEIS


               end
    end
    
    #--------- Otras funciones privadas que necesiteis .......
	
	defp primerLatido(servidor) do
		Process.register(self(),:servidor_sa_aux)
		{atomo,vista,booleano} = ClienteGV.latido(servidor,0)
		latidos(servidor,vista,booleano)
	end
	
	defp latidos(servidor,vista,booleano) do
			cond do
				vista.primario == Node.self() &&  vista.num_vista ==1 ->
					{atomo,nuevavista,booleano} = ClienteGV.latido(servidor, -1)
					latidos(servidor,nuevavista,booleano)
				vista.primario == Node.self() &&  booleano == true && vista.num_vista >2 && vista.copia != :undefined  ->
				IO.puts(vista.copia)
				send({:servidor_sa,vista.primario},{:envia_copia,vista.copia})
				IO.puts("Confirmo Vista")
				{atomo,nuevavista,booleano} = ClienteGV.latido(servidor, vista.num_vista)
				latidos(servidor,nuevavista,booleano)

				vista.num_vista >1 ->
			{atomo,nuevavista,booleano} = ClienteGV.latido(servidor, vista.num_vista)
			latidos(servidor,nuevavista,booleano)
			end
	end
	defp escritura(server,clave,nuevo_valor) do
		bd=Map.put(server.bd,clave,nuevo_valor)
		bd
	end
end
