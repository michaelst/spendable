defmodule Spendable.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: Spendable.Finch},
      # Start the Telemetry supervisor
      SpendableWeb.Telemetry,
      # Start the Ecto repository
      Spendable.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Spendable.PubSub},
      # Start the Endpoint (http/https)
      SpendableWeb.Endpoint
      # Start a worker by calling: Spendable.Worker.start_link(arg)
      # {Spendable.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spendable.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SpendableWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
