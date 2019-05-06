defmodule Server2serverWeb.PageController do
  use Server2serverWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
