defmodule Spendable.MixProject do
  use Mix.Project

  def project() do
    [
      app: :spendable,
      version: "0.1.1",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      test_paths: ["lib"]
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
      {:absinthe_plug, "~> 1.5"},
      {:ash_graphql, "~> 0.25"},
      {:ash_postgres, "~> 1.1"},
      {:ash, "~> 2.10"},
      {:broadway_cloud_pub_sub, "~> 0.7"},
      {:broadway, "~> 1.0"},
      {:castore, "~> 1.0"},
      {:cors_plug, "~> 3.0"},
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.7"},
      {:excoveralls, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.11"},
      {:goth, "~> 1.2"},
      {:guardian, "~> 2.0"},
      {:hammox, "~> 0.6", only: :test},
      {:jason, "~> 1.0"},
      {:kadabra, "~> 0.6"},
      {:logger_json, "~> 5.0"},
      {:mint, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_view, "~> 2.0"},
      {:phoenix, "~> 1.5"},
      {:pigeon, "~> 1.6"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:protobuf, "~> 0.8"},
      {:sentry, "~> 8.0"},
      {:spandex_ecto, "~> 0.7"},
      {:spandex_otlp, github: "michaelst/spandex_otlp"},
      {:spandex_phoenix, "~> 1.0"},
      {:spandex, "~> 3.1"},
      {:tesla, "~> 1.4"},
      {:timex, "~> 3.7"}
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
