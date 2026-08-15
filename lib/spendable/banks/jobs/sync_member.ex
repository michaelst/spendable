defmodule Spendable.Banks.Jobs.SyncMember do
  @moduledoc false

  use Oban.Worker, queue: :banks, max_attempts: 3

  alias Spendable.Banks

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"bank_member_id" => bank_member_id} = args}) do
    Banks.sync_member(bank_member_id, sync_opts(args))
  end

  defp sync_opts(%{"start_date" => start_date}), do: [start_date: Date.from_iso8601!(start_date)]
  defp sync_opts(_args), do: []
end
