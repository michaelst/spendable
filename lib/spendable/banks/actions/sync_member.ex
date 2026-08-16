defmodule Spendable.Banks.Actions.SyncMember do
  @moduledoc false

  import Spendable.Banks.Utils.FormatBankMember

  alias Spendable.Banks
  alias Spendable.Banks.Clients.Plaid
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope

  @page_size 500
  @default_days 30

  @doc """
  Pulls a connection's current state from Plaid: the item, its accounts, and the activity on the
  accounts the user chose to sync.

  Takes an id rather than a record because the only caller is the job queue, which carries ids.
  Runs under a system scope: the work is ours, but the rows are still the member's owner's.
  Activity is pulled from `:start_date`, defaulting to the last #{@default_days} days.

  Plaid only. A FinanceKit connection is read on the device, so there is nothing to pull here.
  """
  def sync_member(bank_member_id, opts \\ []) when is_binary(bank_member_id) do
    case Repo.get(BankMember, bank_member_id) do
      %BankMember{provider: "Plaid"} = bank_member ->
        bank_member = Repo.preload(bank_member, :user)
        scope = Scope.for_system(bank_member.user)
        start_date = opts[:start_date] || Date.add(Date.utc_today(), -@default_days)

        bank_member
        |> sync_item(scope)
        |> sync_accounts(scope)
        |> Enum.filter(& &1.sync)
        |> Enum.each(&sync_transactions(&1, scope, bank_member, start_date))

        :ok

      %BankMember{} ->
        {:error, :not_supported}

      nil ->
        {:error, :bank_member_not_found}
    end
  end

  defp sync_item(bank_member, _scope) do
    {:ok, %{body: item}} = Plaid.item(bank_member.plaid_token)

    {:ok, bank_member} =
      bank_member
      |> BankMember.changeset(format_bank_member(item))
      |> Repo.update()

    bank_member
  end

  # A login that has expired returns no accounts rather than an error, so there is nothing to sync
  # until the user reconnects.
  defp sync_accounts(bank_member, scope) do
    case Plaid.accounts(bank_member.plaid_token) do
      {:ok, %{body: %{"accounts" => accounts}}} ->
        Enum.map(accounts, &upsert_account(&1, bank_member, scope))

      {:ok, %{body: %{"error_code" => "ITEM_LOGIN_REQUIRED"}}} ->
        []
    end
  end

  defp upsert_account(details, bank_member, scope) do
    {:ok, bank_account} =
      Banks.upsert_bank_account(scope, bank_member, format_bank_account(details))

    bank_account
  end

  defp sync_transactions(account, scope, bank_member, start_date, offset \\ 0) do
    opts = [count: @page_size, offset: offset]

    case Plaid.account_transactions(bank_member.plaid_token, account.external_id, start_date, opts) do
      {:ok, %{body: %{"transactions" => transactions} = response}} ->
        entries = Enum.map(transactions, &format_bank_transaction/1)
        {:ok, _ingested} = Banks.ingest_bank_transactions(scope, account, entries)

        with %{"total_transactions" => total} when total > offset + @page_size <- response do
          sync_transactions(account, scope, bank_member, start_date, offset + @page_size)
        end

      {:ok, %{body: %{"error_code" => "PRODUCT_NOT_READY"}}} ->
        :ok
    end
  end

  defp format_bank_account(details) do
    available = Decimal.new("#{details["balances"]["available"] || 0}")
    current = Decimal.new("#{details["balances"]["current"]}")

    balance =
      cond do
        details["type"] == "credit" -> Decimal.mult(current, "-1")
        Decimal.eq?(available, "0") -> current
        true -> available
      end

    %{
      balance: balance,
      external_id: details["account_id"],
      name: details["official_name"] || details["name"],
      number: details["mask"],
      sub_type: details["subtype"],
      type: details["type"]
    }
  end

  # Plaid reports money leaving an account as positive; we store it the way a ledger reads.
  defp format_bank_transaction(details) do
    %{
      amount: details["amount"] |> to_string() |> Decimal.new() |> Decimal.negate() |> Decimal.round(2),
      date: details["date"],
      external_id: details["transaction_id"],
      name: details["name"],
      pending: details["pending"],
      replaces: details["pending_transaction_id"]
    }
  end
end
