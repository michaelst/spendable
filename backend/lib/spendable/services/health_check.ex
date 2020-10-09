defmodule Spendable.Services.HealthCheck do
  use GenServer

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:status, _from, state) do
    if Enum.any?(state, fn {_k, v} -> v == :unhealthy end),
      do: {:reply, :unhealthy, state},
      else: {:reply, :healthy, state}
  end
end
