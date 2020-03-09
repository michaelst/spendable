defmodule Spendable.MixProject do
  use Mix.Project

  def project do
    [
      app: :spendable,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      test_paths: ["test", "lib"]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Spendable.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:absinthe_phoenix, "~> 1.4"},
      {:absinthe_plug, "~> 1.5.0-rc.1", override: true},
      {:absinthe, "~> 1.5.0-rc.2", override: true},
      {:bcrypt_elixir, "~> 2.0"},
      {:castore, "~> 0.1.0"},
      {:credo, "~> 1.3.0", only: [:dev, :test], runtime: false},
      {:dataloader, "~> 1.0.0"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.3"},
      {:ex_machina, "~> 2.4", only: :test},
      {:excoveralls, "~> 0.12.0"},
      {:exq, "~> 0.13.3"},
      {:faker, "~> 0.13", only: :test},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:kadabra, "~> 0.4.4"},
      {:mint, "~> 1.0"},
      {:mock, "~> 0.3", only: :test},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix, "~> 1.4"},
      {:pigeon, "~> 1.5.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:sentry, "~> 7.0"},
      {:tesla, "~> 1.3.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "gen.schema": ["absinthe.schema.json --schema Spendable.Web.Schema"]
    ]
  end
end
