defmodule Spendable.Accounts.Actions.NotifyUser do
  @moduledoc false

  alias Spendable.Accounts.Jobs.SendNotification
  alias Spendable.Scope

  @doc """
  Queues one notification for a user, whatever it took to produce it - a sync that found fifty
  charges is still one push.

  `alert` false sends the silent half only: the app is told the sync finished without the user
  being told anything.
  """
  def notify_user(%Scope{user: %{id: user_id}}, %{count: count, total: total, alert: alert}) do
    %{user_id: user_id, count: count, total: Decimal.to_string(total), alert: alert}
    |> SendNotification.new()
    |> Oban.insert()
  end
end
