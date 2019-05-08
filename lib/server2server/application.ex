defmodule Server2server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      Server2serverWeb.Endpoint,
      {EmieProxy,
       [
         sync_mode: Exconfig.get(:env, :sync_mode),
         sync_slave: Exconfig.get(:env, :sync_slave),
         sync_port: Exconfig.get(:env, :sync_port)
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Server2server.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Server2serverWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
