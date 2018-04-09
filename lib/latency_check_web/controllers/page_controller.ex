defmodule LatencyCheckWeb.PageController do
  use LatencyCheckWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
