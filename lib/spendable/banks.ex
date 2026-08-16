defmodule Spendable.Banks do
  @moduledoc false

  alias Spendable.Banks.Actions

  defdelegate list_bank_members(scope, opts \\ []), to: Actions.ListBankMembers
  defdelegate get_bank_member(scope, by), to: Actions.GetBankMember
  defdelegate get_bank_account(scope, id), to: Actions.GetBankAccount
  defdelegate get_bank_member_by_external_id(external_id), to: Actions.GetBankMemberByExternalId

  defdelegate create_bank_member_from_public_token(scope, public_token),
    to: Actions.CreateBankMemberFromPublicToken

  defdelegate upsert_finance_kit_member(scope), to: Actions.UpsertFinanceKitMember
  defdelegate get_link_token(scope), to: Actions.GetLinkToken
  defdelegate get_update_link_token(scope, bank_member), to: Actions.GetUpdateLinkToken
  defdelegate update_bank_account(scope, bank_account, attrs), to: Actions.UpdateBankAccount
  defdelegate upsert_bank_account(scope, bank_member, attrs), to: Actions.UpsertBankAccount

  defdelegate ingest_bank_transactions(scope, bank_account, entries),
    to: Actions.IngestBankTransactions

  defdelegate calculate_credit_card_balance(scope), to: Actions.CalculateCreditCardBalance
  defdelegate queue_sync(bank_member, opts \\ []), to: Actions.QueueSync
  defdelegate queue_historical_sync(scope, bank_member), to: Actions.QueueHistoricalSync
  defdelegate sync_member(bank_member_id, opts \\ []), to: Actions.SyncMember
end
