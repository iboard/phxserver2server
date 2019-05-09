defmodule EmieProxy.Socket do
  use WebSockex

  def start_link(opts \\ []) do
    IO.inspect(opts, label: "EmieProxy.Socket.start_link")

    # TODO: build url from params
    case WebSockex.start_link("ws://localhost:5000/socket/websocket", __MODULE__, %{},
           name: __MODULE__
         ) do
      {:ok, pid} ->
        ## Process.monitor(pid)

        join_socket(pid)
        |> IO.inspect(label: "EMIEPROXY.SOCKET: returned from WebSockex..send_frame")

        schedule_keep_alive(pid)

        {:ok, pid}

      {:error, error} ->
        IO.inspect(error, label: "EMIEPROXY.SOCKET: WebSockex.start_link can't connect")
        {:error, error}
    end
    |> IO.inspect(label: "EMIEPROXY.SOCKET.start_link sets state to")
  end

  defp join_socket(pid) do
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
  end

  defp schedule_keep_alive(pid) do
    Process.send_after(pid, {:keep_alive, pid}, 10_000)
  end

  def handle_info({:keep_alive, pid}, state) do
    IO.inspect({pid, state}, label: "KEEP_ALIVE")
    schedule_keep_alive(pid)
    {:ok, state}
  end

  def handle_connect(_conn, state) do
    IO.inspect("EMIEPROXY.SOCKET.handle_connect:")
    {:ok, state}
  end

  # HERE WE RECEIVE WEBSOCKET-MESSAGES FROM THE OTHER SIDE (which is
  # mostly but not always the slave)
  # Websockex
  def handle_frame(
        {:text,
         "{\"event\":\"Slave is alive\",\"payload\":{},\"ref\":null,\"topic\":\"proxy:events\"}"},
        state
      ) do
    IO.puts("EMIPROXY.SOCKET handle_frame: send slave_alive to EmieProxy")

    Server2serverWeb.Endpoint.broadcast!(
      "proxy:events",
      "slave_alive",
      %{}
    )
    |> IO.inspect(label: "broadcasted slave_alive to my listeners")

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
    IO.inspect({state, reason}, label: "EMIEPROXY.SOCKET.handle_disconnect_local)")
    {:reconnect, state}
  end

  def handle_disconnect(disconnect_map, state) do
    IO.inspect({disconnect_map, state}, label: "EMIEPROXY.SOCKET.handle_disconnect_map")
    super(disconnect_map, state)
  end
end
