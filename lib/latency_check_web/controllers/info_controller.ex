defmodule LatencyCheckWeb.InfoController do
  use LatencyCheckWeb, :controller

  def index(conn, _params) do
    text conn, "#{Node.self()}|#{Node.get_cookie()}"
  end
end
