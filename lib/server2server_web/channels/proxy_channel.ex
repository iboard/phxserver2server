defmodule Server2serverWeb.ProxyChannel do
  use Server2serverWeb, :channel

  def join(
        "proxy:" <> _subtopic,
        %{"action" => "connect_slave", "token" => token} = payload,
        socket
      ) do
    IO.inspect(token, label: "Server connects with token")
    send(self(), {:after_join, payload})
    {:ok, socket}
  end

  def join("proxy:" <> subtopic, msg, socket) do
    IO.inspect(msg, label: "ProxyChannel: join proxy:#{subtopic} received")
    {:ok, socket}
  end

  defp schedule_keep_alive() do
    Process.send_after(self(), :keep_alive, 10_000)
  end

  #
  # HANDLE INFO
  #
  def handle_info(:keep_alive, socket) do
    broadcast!(socket, "Slave is alive", %{})
    schedule_keep_alive()
    {:noreply, socket}
  end

  def handle_info({:after_join, payload}, socket) do
    IO.inspect(payload, label: "after_join")
    broadcast!(socket, "Slave is connected", payload)
    schedule_keep_alive()
    {:noreply, socket}
  end

  # def handle_info(:slave_connected, socket) do
  #  IO.puts("ProxyChannel :slave_connected")
  #  # TODO: Broadcast on local socket
  #  # broadcast!(socket, "slave_connected", {})

  #  {:noreply, socket}
  # end

  #
  # HANDLE INCOMMING SOCKET MESSAGES FROM FRONTEND
  #

  # (used only on slave)
  def handle_in("request_button", payload, socket) do
    IO.inspect(payload, label: "BACKEND RECEIVED MSG FROM WEB-CLIENT ON SLAVE")
    broadcast!(socket, "slave_request", payload)
    {:noreply, socket}
  end

  # (used only on master)
  def handle_in("connect_server", payload, socket) do
    IO.inspect(payload, label: "RECEIVED server_command")
    {:noreply, socket}
  end

  def handle_in("slave_alive", payload, socket) do
    IO.inspect(payload, label: "FINALY RECEIVED SLAVE ALIVE ON PROXY CHANNEL.")
    {:noreply, socket}
  end

  # FRONTEND CHANNEL
  def handle_in(msg, payload, socket) do
    IO.inspect([msg, payload], label: "RECEIVED UNKOWN MSG")
    {:noreply, socket}
  end

  # WEBSOCKEX CHANNEL
  def handle_in("slave_request", payload, socket) do
    IO.inspect(payload, label: "slave_request")
    {:noreply, socket}
  end
end
