defmodule SpendableWeb.TelemetryTest do
  use ExUnit.Case, async: true

  alias SpendableWeb.Telemetry

  test "init/1 initializes children and handles already attached oban logger" do
    assert {:ok, _children} = Telemetry.init([])
  end
end
