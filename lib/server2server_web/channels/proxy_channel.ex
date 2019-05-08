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

  def handle_info({:after_join, payload}, socket) do
    IO.inspect(payload, label: "after_join")
    broadcast!(socket, "Slave is connected", payload)
    {:noreply, socket}
  end

  def handle_in("request_button", payload, socket) do
    IO.inspect(payload, label: "BACKEND RECEIVED MSG FROM WEB-CLIENT ON SLAVE")
    # TODO: Send message to MASTER-ws via WebSockex
    {:noreply, socket}
  end

  def handle_in("connect_button", payload, socket) do
    if payload["API_KEY"] != 123_456 do
      IO.inspect("UNAUTHORIZED API ACCESS IGNORED")
    else
      IO.inspect(payload, label: "CONNECT BUTTON SENT")

      case EmieProxy.connected?() do
        false ->
          IO.inspect("From Emie.Proxy.start_link: SLAVE IS NOT CONNECTED")

        true ->
          IO.inspect("Already connected!")
      end

      broadcast!(socket, "Server connected!", %{payload: payload})
      |> IO.inspect(label: "BROADCASTED TO CLIENTS")
    end

    {:noreply, socket}
  end

  def handle_in("connect_server", payload, socket) do
    IO.inspect(payload, label: "RECEIVED server_command")
    {:noreply, socket}
  end

  def handle_in(msg, payload, socket) do
    IO.inspect([msg, payload], label: "RECEIVED UNKOWN MSG")
    {:noreply, socket}
  end
end
