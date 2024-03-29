defmodule BroadwayEctoSandbox do
  alias Ecto.Adapters.SQL.Sandbox

  def attach(repo) do
    events = [
      [:broadway, :processor, :start],
      [:broadway, :batch_processor, :start]
    ]

    :telemetry.attach_many({__MODULE__, repo}, events, &handle_event/4, %{repo: repo})
  end

  def handle_event(_event_name, _event_measurement, %{messages: messages}, %{repo: repo}) do
    with [%Broadway.Message{metadata: %{test_process: pid}} | _] <- messages do
      Sandbox.allow(repo, pid, self())
      Hammox.allow(PubSubMock, pid, self())
      Hammox.allow(TeslaMock, pid, self())
    end

    :ok
  end
end
