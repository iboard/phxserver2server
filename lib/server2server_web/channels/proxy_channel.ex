defmodule Server2serverWeb.ProxyChannel do
  use Server2serverWeb, :channel

  def join(
        "proxy:" <> subtopic,
        %{"action" => "connect_slave", "token" => token} = payload,
        socket
      ) do
    IO.inspect(token, label: "Server connects with token")
    send(self, {:after_join, payload})
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

      case EmieProxy.start_link() do
        {:error, reason} ->
          IO.inspect(reason, label: "From Emie.Proxy.start_link: CANT CONNECT SLAVE")

        {:ok, pid} ->
          IO.inspect(pid, label: "From Emie.Proxy.start_link: SLAVE CONNECTED VIA PID")

          # %{topic: "proxy:events", event: "join", payload: "123456", ref: 1}
          frame =
            %{
              topic: "proxy:events",
              event: "phx_join",
              payload: %{action: "connect_slave", token: payload["API_KEY"]},
              ref: 1
            }
            |> Jason.encode!()

          IO.inspect(frame, label: "ProxyChannel is about to send this frame to slave")

          WebSockex.send_frame(pid, {:text, frame})
          |> IO.inspect(label: "returned from WebSockex..send_frame")
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
