defmodule Spendable.Accounts.Jobs.SendNotification do
  @moduledoc false

  use Oban.Worker, queue: :notifications, max_attempts: 5

  alias Spendable.Accounts

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    %{"user_id" => user_id, "count" => count, "total" => total, "alert" => alert} = args

    Accounts.deliver_notification(user_id, %{
      count: count,
      total: Decimal.new(total),
      alert: alert
    })
  end
end
