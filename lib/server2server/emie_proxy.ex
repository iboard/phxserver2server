defmodule EmieProxy do
  use WebSockex

  def start_link(opts \\ []) do
    WebSockex.start_link("ws://localhost:5000/socket/websocket", __MODULE__, :fake_state, opts)
  end

  def handle_connect(_conn, state) do
    IO.inspect("SERVER: connected to slave")
    {:ok, state}
  end
end
