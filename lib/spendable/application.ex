defmodule Spendable.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    all_env_children = [
      {Finch, name: Spendable.Finch},
      SpendableWeb.Telemetry,
      Spendable.Repo,
      {Phoenix.PubSub, name: Spendable.PubSub},
      SpendableWeb.Endpoint,
      Spendable.Broadway.SyncMember
    ]

    prod_children = [
      {Goth, name: Spendable.Goth}
    ]

    children =
      if Application.get_env(:spendable, :env) == :prod do
        all_env_children ++ prod_children
      else
        all_env_children
      end

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
