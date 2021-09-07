defmodule Spendable.Notifiers.SyncMember do
  use Ash.Notifier

  alias Spendable.Publishers.SyncMemberRequest

  require Logger

  def notify(%Ash.Notifier.Notification{
        resource: Spendable.BankAccount,
        action: %{type: :update},
        data: %{sync: true},
        changeset: %{data: %{bank_member_id: bank_member_id}}
      }) do
    Logger.info("publishing sync member request for member: #{bank_member_id}")
    SyncMemberRequest.publish(bank_member_id)
  end

  def notify(_notification) do
    :ok
  end
end
