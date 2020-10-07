defmodule Spendable.Services.HealthCheck do
  use GenServer

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    Process.send_after(self(), :weddell, 10 * 1000)

    {:ok,
     %{
       weddell: :unhealthy
     }}
  end

  @impl true
  def handle_info(:weddell, state) do
    case weddell_status() do
      :healthy ->
        Process.send_after(self(), :weddell, 60 * 1000)
        {:noreply, Map.put(state, :weddell, :healthy)}

      :unhealthy ->
        Process.send_after(self(), :weddell, 5 * 1000)
        {:noreply, Map.put(state, :weddell, :unhealthy)}
    end
  end

  @impl true
  def handle_call(:status, _, state) do
    if Enum.all?(state, fn {_k, v} -> v == :healthy end),
      do: {:reply, :healthy, state},
      else: {:reply, :unhealthy, state}
  end

  defp weddell_status() do
    {:ok, _} = Weddell.topics([], 1000)
    :healthy
  rescue
    _ -> :unhealthy
  end
end
