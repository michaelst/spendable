defmodule Spendable.MixProject do
  use Mix.Project

  def project() do
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
  def application() do
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
      {:ash_graphql, "~> 0.16"},
      {:ash_policy_authorizer, "~> 0.16"},
      {:ash_postgres, "~> 0.40"},
      {:ash, "~> 1.47"},
      {:broadway_cloud_pub_sub, "~> 0.7"},
      {:broadway, "~> 1.0"},
      {:castore, "~> 0.1.0"},
      {:cors_plug, "~> 2.0"},
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.7"},
      {:ex_machina, "~> 2.7", only: :test},
      {:excoveralls, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.11"},
      {:goth, "~> 1.2"},
      {:guardian, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:kadabra, "~> 0.6"},
      {:logger_json, "~> 4.0"},
      {:mint, "~> 1.0"},
      {:mock, "~> 0.3", only: :test},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix, "~> 1.5"},
      {:pigeon, "~> 1.6"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:protobuf, "~> 0.7.1"},
      {:sentry, "~> 8.0"},
      {:tesla, "~> 1.4"}
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
      "ash.gen.migrations": ["ash_postgres.generate_migrations"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "gen.schema": ["absinthe.schema.json --schema Spendable.Web.Schema"]
    ]
  end
end
