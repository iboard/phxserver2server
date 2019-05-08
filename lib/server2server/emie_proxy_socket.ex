defmodule EmieProxy.Socket do
  use WebSockex

  def start_link(opts \\ []) do
    IO.inspect(opts, label: "EmieProxy.Socket.start_link")

    case WebSockex.start_link("ws://localhost:5000/socket/websocket", __MODULE__, %{}, opts) do
      {:ok, pid} ->
        Process.monitor(pid)

        frame =
          %{
            topic: "proxy:events",
            event: "phx_join",
            payload: %{
              action: "connect_slave",
              token: Exconfig.get(:env, :server2server_token, 123_456)
            },
            ref: 1
          }
          |> Jason.encode!()

        WebSockex.send_frame(pid, {:text, frame})
        |> IO.inspect(label: "EMIEPROXY.SOCKET: returned from WebSockex..send_frame")

        {:ok, pid}

      {:error, error} ->
        IO.inspect(error, label: "EMIEPROXY.SOCKET: WebSockex.start_link can't connect")
        {:error, error}
    end
    |> IO.inspect(label: "EMIEPROXY.SOCKET.start_link sets state to")
  end

  def handle_connect(_conn, state) do
    IO.inspect("EMIEPROXY.SOCKET.handle_connect:")
    {:ok, state}
  end

  def handle_frame({:text, msg}, state) do
    IO.inspect(msg, label: "EMIEPROXY.SOCKET.handle_frame (:text,msg)")
    {:ok, state}
  end

  def handle_frame(payload, state) do
    IO.inspect({payload, state}, label: "EMIEPROXY.SOCKET.handle_frame (unknown)")
    {:ok, state}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    IO.inspect({state, reason}, label: "EMIEPROXY.SOCKET.handle_disconnect")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    IO.inspect({disconnect_map, state}, label: "EMIEPROXY.SOCKET.handle_disconnect")
    super(disconnect_map, state)
  end
end
