defmodule LatencyCheck.CnC do
  use GenServer
  require Logger

  # Public API
 
  def list() do
    GenServer.call(__MODULE__, :list)
  end

  def query(url, id) do
    Node.list
    |> Enum.each(&(GenServer.cast({LatencyCheckClient, &1}, {:query, url, id})))
  end

  # Private API

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    %{"query" => ip, "countryCode" => countryCode} = 
      HTTPoison.get!("http://ip-api.com/json")
      |> Map.get(:body)
      |> Poison.decode!

    Node.start(:"#{UUID.uuid4(:hex)}@127.0.0.1")
    Node.set_cookie(String.to_atom(UUID.uuid4(:hex)))

    {:ok, state}
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:register, {node, ip, country_code}}, _from, state) do
    Node.monitor(node, true)
    LatencyCheckWeb.Endpoint.broadcast! "room:lobby", "new_node", %{node: [ip, country_code]}
    {:reply, "Hello #{node}", Map.put(state, node, [ip, country_code])}
  end

  def handle_cast({:result, {id, time, node}}, state) do
    LatencyCheckWeb.Endpoint.broadcast! "room:" <> id, "node_result", %{node: node, time: time}
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    LatencyCheckWeb.Endpoint.broadcast! "room:lobby", "node_down", %{id: node}
    {:noreply, Map.delete(state, node)}
  end
  
  def handle_info(info, state) do
    Logger.warn("UNHANDLED_INFO: #{inspect info}")
    {:noreply, state}
  end
end
