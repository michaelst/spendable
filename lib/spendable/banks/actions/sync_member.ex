defmodule Spendable.Banks.Actions.SyncMember do
  @moduledoc false

  import Ecto.Query
  import Spendable.Banks.Utils.FormatBankMember

  alias Spendable.Accounts
  alias Spendable.Banks.Clients.Plaid
  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Banks.Schemas.BankTransaction
  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions

  @page_size 500
  @default_days 30

  @doc """
  Pulls a connection's current state from Plaid: the item, its accounts, and the activity on the
  accounts the user chose to sync.

  Takes an id rather than a record because the only caller is the job queue, which carries ids.
  Runs under a system scope: the work is ours, but the rows are still the member's owner's.
  Activity is pulled from `:start_date`, defaulting to the last #{@default_days} days.

  Notifies the user once at the end, never per charge. `notify: false` keeps the alert back on a
  run that is expected to be large - the first sync of a connection, or a backfill the user is
  already watching - while still telling the app the run finished.
  """
  def sync_member(bank_member_id, opts \\ []) when is_binary(bank_member_id) do
    case Repo.get(BankMember, bank_member_id) do
      %BankMember{} = bank_member ->
        bank_member = Repo.preload(bank_member, :user)
        scope = Scope.for_system(bank_member.user)
        start_date = opts[:start_date] || Date.add(Date.utc_today(), -@default_days)

        bank_member
        |> sync_item(scope)
        |> sync_accounts(scope)
        |> Enum.filter(& &1.sync)
        |> Enum.flat_map(&sync_transactions(&1, scope, bank_member, start_date))
        |> notify(scope, opts)

      nil ->
        {:error, :bank_member_not_found}
    end
  end

  defp notify(bank_transactions, scope, opts) do
    total = Enum.reduce(bank_transactions, Decimal.new(0), &Decimal.add(&2, &1.amount))

    {:ok, _job} =
      Accounts.notify_user(scope, %{
        count: length(bank_transactions),
        total: total,
        alert: Keyword.get(opts, :notify, true)
      })

    :ok
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
    attrs = format_bank_account(details)

    account =
      Repo.get_by(BankAccount, user_id: scope.user.id, external_id: details["account_id"]) ||
        %BankAccount{user_id: scope.user.id, bank_member_id: bank_member.id}

    {:ok, account} = account |> BankAccount.changeset(attrs) |> Repo.insert_or_update()

    account
  end

  defp sync_transactions(account, scope, bank_member, start_date, offset \\ 0) do
    opts = [count: @page_size, offset: offset]

    case Plaid.account_transactions(bank_member.plaid_token, account.external_id, start_date, opts) do
      {:ok, %{body: %{"transactions" => transactions} = response}} ->
        synced = Enum.flat_map(transactions, &sync_transaction(&1, account, scope))

        rest =
          with %{"total_transactions" => total} when total > offset + @page_size <- response do
            sync_transactions(account, scope, bank_member, start_date, offset + @page_size)
          else
            _last_page -> []
          end

        synced ++ rest

      {:ok, %{body: %{"error_code" => "PRODUCT_NOT_READY"}}} ->
        []
    end
  end

  # Plaid replays transactions we already hold, so a duplicate external id is the normal case and
  # not an error worth failing the sync over. Returns the inserts, which are what the user is told
  # about.
  defp sync_transaction(details, account, scope) do
    attrs = format_bank_transaction(details)

    %BankTransaction{user_id: scope.user.id, bank_account_id: account.id}
    |> BankTransaction.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, bank_transaction} ->
        create_transaction(bank_transaction, details, scope)

        [bank_transaction]

      {:error, _already_synced} ->
        []
    end
  end

  defp create_transaction(bank_transaction, details, scope) do
    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "amount" => bank_transaction.amount,
        "date" => bank_transaction.date,
        "name" => bank_transaction.name,
        "reviewed" => false,
        "bank_transaction_id" => bank_transaction.id
      })

    replace_pending(transaction, details, scope)
  end

  # A pending transaction is replaced by a settled one under a new id. The user may already have
  # allocated the pending one, so its allocations move across rather than being asked for twice.
  defp replace_pending(transaction, %{"pending_transaction_id" => pending_id}, scope)
       when is_binary(pending_id) do
    query =
      from(bank_transaction in BankTransaction,
        where: bank_transaction.external_id == ^pending_id,
        where: bank_transaction.pending == true,
        preload: [:transaction]
      )

    case Repo.one(query) do
      %BankTransaction{transaction: %{} = pending} = bank_transaction ->
        {:ok, _moved} = Transactions.replace_pending(scope, pending, transaction)
        Repo.delete(bank_transaction)

      _nothing_to_replace ->
        :ok
    end
  end

  defp replace_pending(_transaction, _details, _scope), do: :ok

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
      pending: details["pending"]
    }
  end
end
