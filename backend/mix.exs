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
      {:absinthe_plug, "~> 1.5.0-rc.0"},
      {:absinthe, "~> 1.5.0-rc.0"},
      {:bcrypt_elixir, "~> 2.0"},
      {:broadway_cloud_pub_sub, "~> 0.6.0"},
      {:broadway, "~> 0.6.0"},
      {:castore, "~> 0.1.0"},
      {:certifi, "~> 2.5.2", override: true},
      {:cors_plug, "~> 2.0"},
      {:cowlib, "~> 2.8", override: true},
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false},
      {:dataloader, "~> 1.0.0"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.3"},
      {:ex_machina, "~> 2.4", only: :test},
      {:excoveralls, "~> 0.12.0"},
      {:faker, "~> 0.13", only: :test},
      {:gettext, "~> 0.11"},
      {:goth, "~> 1.2"},
      {:guardian, "~> 2.0"},
      {:hackney, "~> 1.15.2", override: true},
      {:jason, "~> 1.0"},
      {:kadabra, "~> 0.4.4"},
      {:mint, "~> 1.0"},
      {:mock, "~> 0.3", only: :test},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix, "~> 1.5"},
      {:pigeon, "~> 1.5.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:protobuf, "~> 0.7.1"},
      {:sentry, "~> 7.0"},
      {:tesla, "~> 1.3.2"},
      {:weddell, "~> 0.1"}
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
