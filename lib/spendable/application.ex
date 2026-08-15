defmodule Spendable.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: Spendable.Finch},
      SpendableWeb.Telemetry,
      Spendable.Repo,
      {Oban, Application.fetch_env!(:spendable, Oban)},
      {Phoenix.PubSub, name: Spendable.PubSub},
      SpendableWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spendable.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  # coveralls-ignore-start OTP only calls this on a hot code upgrade, which no test run performs
  @impl true
  def config_change(changed, _new, removed) do
    SpendableWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # coveralls-ignore-stop
end
