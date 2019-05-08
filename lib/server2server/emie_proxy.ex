defmodule EmieProxy do
  use GenServer

  defp initial_socket_state(opts) do
    %{options: opts, connected: false, pid: nil, errors: []}
  end

  #
  # GenServer API
  #
  def start_link(opts \\ []) do
    IO.inspect(opts, label: "EmieProxy.start_link")
    socket_state = initial_socket_state(opts)

    GenServer.start_link(__MODULE__, socket_state, name: __MODULE__)
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    IO.inspect(state, label: "EMIEPROXY.init")

    if Exconfig.get(:env, :sync_mode) == "master" do
      Process.send_after(self(), :try_connect_socket, 10_000)
      |> IO.inspect(label: "EMIEPROXY.init schedule :try_connect_socket in 10secs")
    end

    {:ok, state}
  end

  #
  # EmieProxy API
  #
  def connected?() do
    GenServer.call(__MODULE__, :connected?)
  end

  #
  # GenServer Callbacks
  #

  # Info handling
  def handle_info(:try_connect_socket, state) do
    IO.inspect(state, label: "EMIEPROXY.handle_info :try_connect_socket, begin with state")

    proxy_state =
      case EmieProxy.Socket.start_link() |> IO.inspect(label: "Socket.start_link") do
        {:already_started, _pid} ->
          state

        {:error, error} ->
          IO.inspect(error, label: "EmieProxy.Socket can't connect to slave")

          Process.send_after(self(), :try_connect_socket, 10_000)
          |> IO.inspect(label: "Schedule retry in 10secs")

          %{state | connected: false, pid: nil, errors: [error | state.errors]}

        {:ok, pid} ->
          IO.inspect(pid, label: "EmieProxy.Socket started on pid")
          Process.monitor(pid)
          %{state | connected: true, pid: pid}
      end

    IO.inspect(proxy_state, label: "EMIPROXY.handle_info :try_connect_socket sets state to")
    {:noreply, proxy_state}
  end

  def handle_info(unknown, state) do
    IO.inspect({unknown, state}, label: "EMIEPROXY.handle_info :unknown message")
    {:noreply, state}
  end

  ## Synchronous handling

  def handle_call(:connected?, _from, state) do
    {:reply, state.connected, state}
  end
end
