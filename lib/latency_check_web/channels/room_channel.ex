defmodule LatencyCheckWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    nodes = LatencyCheck.CnC.list
    {:ok, %{nodes: nodes}, socket}
  end

  def join("room:" <> _uuid, _message, socket) do
    {:ok, socket}
  end

  def handle_in("start_query", %{"url" => url}, socket) do
    "room:" <> uuid = socket.topic
    LatencyCheck.CnC.query(url, uuid)
    {:noreply, socket}
  end
end
