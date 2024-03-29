require IEx # Para utilizar IEx.pry

defmodule ServidorGV do
    @moduledoc """
        modulo del servicio de vistas
    """

    # Tipo estructura de datos que guarda el estado del servidor de vistas
    # COMPLETAR  con lo campos necesarios para gestionar
    # el estado del gestor de vistas
    defstruct   numVista: 0, primario: :undefined, copia: :undefined, nodoEspera: :undefined, tentativa: true, valida: false

    # Constantes
    @latidos_fallidos 4

    @intervalo_latidos 50


    @doc """
        Acceso externo para constante de latidos fallios
    """
    def latidos_fallidos() do
        @latidos_fallidos
    end

    @doc """
        acceso externo para constante intervalo latido
    """
   def intervalo_latidos() do
       @intervalo_latidos
   end

   @doc """
        Generar un estructura de datos vista inicial
    """
    def vista_inicial() do
        %{num_vista: 0, primario: :undefined, copia: :undefined}
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
    @spec startService(node) :: boolean
    def startService(nodoElixir) do
        NodoRemoto.esperaNodoOperativo(nodoElixir, __MODULE__)

        # Poner en marcha el código del gestor de vistas
        Node.spawn(nodoElixir, __MODULE__, :init_sv, [])
   end

    #------------------- FUNCIONES PRIVADAS ----------------------------------

    # Estas 2 primeras deben ser defs para llamadas tipo (MODULE, funcion,[])
    def init_sv() do
        Process.register(self(), :servidor_gv)

        spawn(__MODULE__, :init_monitor, [self()]) # otro proceso concurrente

        state=%ServidorGV{}

        bucle_recepcion(state,0,0,false)
    end

    def init_monitor(pid_principal) do
        send(pid_principal, :procesa_situacion_servidores)
        Process.sleep(@intervalo_latidos)
        init_monitor(pid_principal)
    end


    defp bucle_recepcion(state,numPrimario,numCopia,error) do
        receive do
                    {:latido, n_vista_latido, nodo_emisor} ->  error= procesa_error_latido(state,n_vista_latido,nodo_emisor,error)
															   state= procesa_latido(state,n_vista_latido,nodo_emisor,error)
															   vista= %{num_vista: state.numVista, primario: state.primario, copia: state.copia}
															   send({:servidor_sa_aux,nodo_emisor},{:vista_tentativa,vista,state.tentativa})
															   if (nodo_emisor== state.primario) do 
															   bucle_recepcion(state,0,numCopia,error)
															   end
															   if (nodo_emisor== state.copia) do
															   bucle_recepcion(state,numPrimario,0,error)
															   end
															   bucle_recepcion(state,numPrimario,numCopia,error)

                        ### VUESTRO CODIGO

                    {:obten_vista, pid} -> vista= %{num_vista: state.numVista, primario: state.primario, copia: state.copia}
										   send(pid,{:vista_valida,vista,state.valida})
										   bucle_recepcion(state,numPrimario,numCopia,error)

                        ### VUESTRO CODIGO

                    :procesa_situacion_servidores -> cond do
													 state.primario == :undefined && state.copia == :undefined ->
																	bucle_recepcion(state,0,0,error)
													 state.copia == :undefined ->
																	numPrimario= numPrimario + 1
																	cond do
																		numPrimario < @latidos_fallidos -> bucle_recepcion(state,numPrimario,0,false)
																		numPrimario == @latidos_fallidos -> 
																						res= evaluarContinuidad(state,numPrimario,numCopia,error)
																						cond do 
																							res == false -> bucle_recepcion(state,0,0,not res)
																							true -> state= evaluarCaidas(state,numPrimario,numCopia)
																											bucle_recepcion(state,0,0,not res)
																						end
																	end
													 true ->
															numPrimario= numPrimario + 1
															numCopia= numCopia + 1
															cond do 
																numPrimario == @latidos_fallidos && numCopia == @latidos_fallidos ->
																					bucle_recepcion(state,0,0,true)
																numPrimario == @latidos_fallidos ->
																	res = evaluarContinuidad(state,numPrimario,numCopia,error)
																	cond do 
																							res == false -> bucle_recepcion(state,0,0,not res)
																							true -> state= evaluarCaidas(state,numPrimario,numCopia)
																											bucle_recepcion(state,0,numCopia,not res)
																	end
																numCopia == @latidos_fallidos ->
																	res = evaluarContinuidad(state,numPrimario,numCopia,error)
																	cond do 
																							res == false -> bucle_recepcion(state,0,0,not res)
																							true -> state= evaluarCaidas(state,numPrimario,numCopia)
																											bucle_recepcion(state,numPrimario,0,not res)
																	end
																true -> bucle_recepcion(state,numPrimario,numCopia,false)
															end
													end
                        ### VUESTRO CODIGO

        end
    end
	
	def procesa_error_latido(state,n_vista_latido,nodo_emisor,error) do
		cond do
			error == true -> true
			n_vista_latido == 0 && nodo_emisor == state.primario && state.copia == :undefined -> true
			n_vista_latido == 0 && nodo_emisor == state.primario && state.valida == false -> true
			true 	-> false
		end
	end
	
	def procesa_latido(state,n_vista_latido,nodo_emisor,error) do
		cond do 
			error == true -> state=%ServidorGV{}
							 state
			n_vista_latido == 0 && nodo_emisor == state.primario && state.copia != :undefined && (state.nodoEspera == :undefined || state.nodoEspera == []) -> state= %{state| primario: state.copia, copia: nodo_emisor, numVista: state.numVista + 1, tentativa: true, valida: false}
																																   state
			n_vista_latido == 0 && nodo_emisor == state.primario && state.copia != :undefined && state.nodoEspera != :undefined -> state= %{state| primario: state.copia, copia: hd(state.nodoEspera), nodoEspera: tl(state.nodoEspera) ++ [nodo_emisor], numVista: state.numVista + 1, tentativa: true, valida: false}
																																   state
			n_vista_latido == 0 && nodo_emisor == state.copia && (state.nodoEspera == :undefined || state.nodoEspera == []) -> state= %{state| copia: nodo_emisor, numVista: state.numVista + 1, tentativa: true, valida: false}
																								   state
			n_vista_latido == 0 && nodo_emisor == state.copia && state.nodoEspera != :undefined -> state= %{state| copia: hd(state.nodoEspera), nodoEspera: tl(state.nodoEspera) ++ [nodo_emisor], numVista: state.numVista + 1, tentativa: true, valida: false}
																								   state
			n_vista_latido == 0 && state.primario == :undefined -> 	nuevaVista = state.numVista + 1
																	state= %{state| primario: nodo_emisor, numVista: nuevaVista}
																	state
			n_vista_latido== -1 								->  state
			n_vista_latido == 0 && state.copia == :undefined    ->	nuevaVista = state.numVista + 1
																	state= %{state| copia: nodo_emisor, numVista: nuevaVista}
																	state
			n_vista_latido == state.numVista && state.primario == nodo_emisor && state.tentativa== true -> state= %{state| tentativa: false, valida: true}
																										   state
			n_vista_latido >0   -> state
			n_vista_latido == 0 && (state.nodoEspera == :undefined || state.nodoEspera == []) -> state= %{state | nodoEspera: [nodo_emisor]}
																	 state
			n_vista_latido == 0 && state.nodoEspera != :undefined -> state= %{state | nodoEspera: state.nodoEspera ++ [nodo_emisor]}
																	 state
		end
	end
	
	def evaluarContinuidad(state,numPrimario,numCopia,error) do
	  cond do
		error == true -> false
		numPrimario == @latidos_fallidos && numCopia == @latidos_fallidos ->false
		numPrimario == @latidos_fallidos && state.copia == :undefined && state.numVista > 1 -> 	false
		true 															  -> true
	  end
	end
	
	def evaluarCaidas(state,numPrimario,numCopia) do
	  cond do
	    numPrimario == @latidos_fallidos && state.copia != :undefined && (state.nodoEspera == :undefined || state.nodoEspera == [])  -> state= %{state | primario: state.copia, copia: :undefined, valida: false, tentativa: true, numVista: state.numVista + 1}
																											state
		numPrimario == @latidos_fallidos && state.copia != :undefined && state.nodoEspera != :undefined  -> state= %{state | primario: state.copia, copia: hd(state.nodoEspera), nodoEspera: tl(state.nodoEspera), valida: false, tentativa: true, numVista: state.numVista + 1}
																										    state
		numPrimario == @latidos_fallidos && state.copia == :undefined  -> state=%ServidorGV{}
																		  state
		numCopia == @latidos_fallidos && state.nodoEspera != :undefined -> state= %{state | copia: hd(state.nodoEspera), nodoEspera: tl(state.nodoEspera), valida: false, tentativa: true, numVista: state.numVista + 1}
																	       state
		numCopia == @latidos_fallidos && (state.nodoEspera == :undefined || state.nodoEspera == []) -> state= %{state | copia: :undefined, valida: false, tentativa: true, numVista: state.numVista + 1}
																		   state
		true  ->state
      end
	end

    # OTRAS FUNCIONES PRIVADAS VUESTRAS

end
