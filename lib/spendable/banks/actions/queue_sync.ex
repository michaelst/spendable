defmodule Spendable.Banks.Actions.QueueSync do
  @moduledoc false

  alias Spendable.Banks.Jobs.SyncMember
  alias Spendable.Banks.Schemas.BankMember

  @doc "Syncing talks to Plaid for as long as it takes, so it never runs in the request."
  def queue_sync(%BankMember{} = bank_member) do
    %{bank_member_id: bank_member.id}
    |> SyncMember.new()
    |> Oban.insert()
  end
end
