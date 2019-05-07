defmodule Server2serverWeb.ProxyChannel do
  use Phoenix.Channel

  def join("proxy:events", msg, socket) do
    IO.inspect(msg, label: "join proxy::events receive")
    {:ok, socket}
  end

  def handle_in("connect_button", payload, socket) do
    if payload["API_KEY"] != 123_456 do
      IO.inspect("UNAUTHORIZED API ACCESS IGNORED")
    else
      IO.inspect(payload, label: "Accepting connection request from master")

      broadcast!(socket, "Server connected!", payload)
      |> IO.inspect(label: "BROADCASTED TO CLIENTS")
    end

    {:noreply, socket}
  end
end
