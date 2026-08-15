defmodule Spendable.Banks.Jobs.SyncMember do
  @moduledoc false

  use Oban.Worker, queue: :banks, max_attempts: 3

  alias Spendable.Banks

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"bank_member_id" => bank_member_id}}) do
    Banks.sync_member(bank_member_id)
  end
end
