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

		IO.puts("Inicio servicio")
		server= %ServidorSA{}
		spawn(fn -> primerLatido(nodo_servidor_gv) end)
         # Poner estado inicial
        bucle_recepcion_principal(server) 
    end


    defp bucle_recepcion_principal(server) do
        receive do

                    # Solicitudes de lectura y escritura
                    # de clientes del servicio alm.
                  {op, param, nodo_origen}  ->


                        # ----------------- vuestro código


                  # --------------- OTROS MENSAJES QUE NECESITEIS


               end

        bucle_recepcion_principal(server)
    end
    
    #--------- Otras funciones privadas que necesiteis .......
	
	defp primerLatido(servidor) do
		Process.register(:servidor_sa_aux,self())
		IO.puts("Voy a enviar latido")
		ClienteGV.latido(servidor,0)
		latidos(servidor)
	end
	
	defp latidos(servidor) do
		receive do
		{:vista_tentativa,vista,es_tentativa} -> 
			IO.puts("Vista recibida, escribo primario nuevo")
			IO.puts(vista.primario)
			cond do
				vista.primario == Node.self() && es_tentativa && vista.numVista ==1 ->
					ClienteGV.latido(servidor, -1)
				vista.numVista >1 -> ClienteGV.latido(servidor, vista.numVista)
			end
		end
		latidos(servidor)
	end
end
