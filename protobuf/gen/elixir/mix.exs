defmodule SpendableProtos.MixProject do
  use Mix.Project

  def project do
    [
      app: :spendable_protos,
      version: "1.0.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:protobuf, "~> 0.11"}
    ]
  end
end
