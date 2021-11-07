defmodule Spendable.Notifiers.SyncMember do
  use Ash.Notifier

  alias Spendable.Broadway.SyncMember
  alias Spendable.Publishers.SyncMemberRequest

  require Logger

  def notify(%Ash.Notifier.Notification{
        resource: Spendable.BankMember,
        action: %{name: :create_from_public_token},
        data: %{id: bank_member_id} = member
      }) do
    SyncMember.sync_accounts(member)
    Logger.info("publishing sync member request for member: #{bank_member_id}")
    SyncMemberRequest.publish(bank_member_id)
  end

  def notify(_notification) do
    :ok
  end
end
