defmodule Spendable.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Spendable.Web.Endpoint

  def start(_type, _args) do
    children = [
      Spendable.Repo,
      Spendable.Web.Endpoint,
      Spendable.Broadway.SendNotification,
      Spendable.Broadway.SyncMember,
      Spendable.Services.HealthCheck,
      Spendable.Auth.Guardian.KeyServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spendable.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
