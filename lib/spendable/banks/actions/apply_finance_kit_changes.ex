defmodule Spendable.Banks.Actions.ApplyFinanceKitChanges do
  @moduledoc false

  alias Spendable.Banks
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope

  @kinds %{
    "credit_card" => {"credit", "credit card"},
    "cash" => {"depository", "checking"},
    "savings" => {"depository", "savings"}
  }

  @doc """
  Records what the device read out of Wallet since its last read.

  Refuses when `history_token_before` is not where we think the device left off, so a client that
  lost a response finds out rather than skipping a batch. Replaying a batch we did hold applies
  nothing, because the accounts upsert and the charges dedupe on their external ids.

  Wallet reports an unsigned amount and says whether it was a credit or a debit, so the sign is
  put on here - one rule for balances and charges alike - and the account kinds are mapped onto
  the vocabulary the table already uses.
  """
  def apply_finance_kit_changes(
        %Scope{user: %{id: user_id}} = scope,
        %BankMember{user_id: user_id, provider: "FinanceKit"} = bank_member,
        changes
      ) do
    if bank_member.history_token == changes["history_token_before"] do
      Repo.transaction(fn -> apply_changes(scope, bank_member, changes) end)
    else
      {:error, :history_token_mismatch}
    end
  end

  def apply_finance_kit_changes(
        %Scope{user: %{id: user_id}},
        %BankMember{user_id: user_id},
        _changes
      ) do
    {:error, :not_supported}
  end

  def apply_finance_kit_changes(_scope, _bank_member, _changes), do: {:error, :not_authorized}

  defp apply_changes(scope, bank_member, changes) do
    accounts =
      changes
      |> Map.get("accounts", [])
      |> Map.new(&upsert_account(scope, bank_member, &1))

    applied =
      insert_charges(scope, accounts, changes["inserted"] || []) +
        update_charges(scope, changes["updated"] || []) +
        delete_charges(scope, changes["deleted"] || [])

    {:ok, updated} =
      bank_member
      |> BankMember.changeset(%{history_token: changes["history_token_after"]})
      |> Repo.update()

    %{applied: applied, history_token: updated.history_token}
  end

  defp upsert_account(scope, bank_member, account) do
    {type, sub_type} = Map.fetch!(@kinds, account["kind"])

    {:ok, bank_account} =
      Banks.upsert_bank_account(scope, bank_member, %{
        balance: signed(account["credit_debit_indicator"], account["balance"]),
        external_id: account["external_id"],
        name: account["name"],
        sub_type: sub_type,
        type: type
      })

    {bank_account.external_id, bank_account}
  end

  # Charges are grouped so an account is written once per batch rather than once per charge.
  defp insert_charges(scope, accounts, charges) do
    charges
    |> Enum.group_by(& &1["account_external_id"], &entry/1)
    |> Enum.reduce(0, fn {external_id, entries}, applied ->
      {:ok, ingested} =
        Banks.ingest_bank_transactions(scope, Map.fetch!(accounts, external_id), entries)

      applied + ingested
    end)
  end

  # A charge we never held is inserted rather than dropped: the device may be resuming from a
  # batch whose response never reached it.
  defp update_charges(scope, charges) do
    Enum.count(charges, fn charge ->
      case Banks.get_bank_transaction(scope, external_id: charge["external_id"]) do
        {:ok, bank_transaction} ->
          {:ok, _updated} = Banks.update_bank_transaction(scope, bank_transaction, entry(charge))
          true

        {:error, :bank_transaction_not_found} ->
          false
      end
    end)
  end

  defp delete_charges(scope, external_ids) do
    Enum.count(external_ids, fn external_id ->
      case Banks.get_bank_transaction(scope, external_id: external_id) do
        {:ok, bank_transaction} ->
          {:ok, _deleted} = Banks.delete_bank_transaction(scope, bank_transaction)
          true

        {:error, :bank_transaction_not_found} ->
          false
      end
    end)
  end

  defp entry(charge) do
    %{
      amount: signed(charge["credit_debit_indicator"], charge["amount"]),
      date: charge["date"],
      external_id: charge["external_id"],
      name: charge["name"],
      pending: charge["pending"],
      replaces: nil
    }
  end

  # Money in is a credit, money out a debit, and a card's balance is a debit because it is owed.
  defp signed("debit", amount), do: amount |> Decimal.new() |> Decimal.negate()
  defp signed(_credit, amount), do: Decimal.new(amount)
end
