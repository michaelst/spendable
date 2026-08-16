defmodule Spendable.MixProject do
  use Mix.Project

  def project do
    [
      app: :spendable,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      listeners: [Phoenix.CodeReloader],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      test_paths: ["lib"]
    ]
  end

  def cli() do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.json": :test,
        "coveralls.html": :test
      ]
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
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:anubis_mcp, "~> 2.0"},
      {:bandit, "~> 1.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:spendable_credo, path: "credo", only: [:dev, :test], runtime: false},
      {:dotenv_parser, "~> 2.0", only: [:dev]},
      {:ecto_sql, "~> 3.14"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:excoveralls, ">= 0.0.0", only: :test},
      {:finch, "~> 0.13"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:gettext, "~> 1.0"},
      {:hammox, "~> 1.0", only: :test},
      {:jason, "~> 1.2"},
      {:joken, "~> 2.6"},
      {:oban, "~> 2.19"},
      {:open_api_spex, "~> 3.21"},
      {:logger_json, "~> 7.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.2"},
      {:phoenix, "~> 1.8"},
      {:postgrex, ">= 0.0.0"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:tesla, "~> 1.4"},
      {:ueberauth_google, "~> 0.10"},
      {:ueberauth, "~> 0.10"},
      {:uxid, "~> 2.9"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": [
        "cmd --cd assets pnpm install --frozen-lockfile",
        "tailwind.install --if-missing",
        "esbuild.install --if-missing"
      ],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      credo: ["credo --config-file credo/.credo.exs"],
      # The spec is read off the router and the controller modules, so booting the app - and with
      # it a database - buys nothing.
      openapi: [
        "openapi.spec.json --spec SpendableWeb.Api.ApiSpec --pretty --no-start-app --filename priv/static/openapi.json"
      ]
    ]
  end
end
