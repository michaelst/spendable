defmodule Budget.Jobs.Banks.SyncMember do
  alias Budget.Banks.Member
  alias Budget.Banks.Account
  alias Budget.Repo
  alias Budget.Banks.Providers.Plaid.Adapter
  alias Budget.Banks.Transaction, as: BankTransaction
  alias Budget.Transaction

  def perform(user_id, external_id) do
    member = Repo.get_by!(Member, external_id: external_id)
    {:ok, %{body: details}} = Plaid.member(member.plaid_token)

    member =
      member
      |> Member.changeset(Adapter.format(details, user_id, :member))
      |> Repo.update!()

    {:ok, %{body: %{"accounts" => accounts_details}}} = Plaid.accounts(member.plaid_token)

    accounts =
      Enum.map(accounts_details, fn account_details ->
        Repo.get_by(Account, user_id: user_id, external_id: account_details["account_id"])
        |> case do
          nil -> struct(Account)
          account -> account
        end
        |> Account.changeset(Adapter.format(account_details, member.id, user_id, :account))
        |> Repo.insert_or_update!()
      end)

    Enum.each(accounts, fn account -> sync_transactions(member, account) end)
  end

  defp sync_transactions(member, account, opts \\ []) do
    count = opts[:count] || 500
    offset = opts[:offset] || 0
    cursor = offset + count

    {:ok, %{body: %{"transactions" => transactions_details} = response}} =
      Plaid.account_transactions(member.plaid_token, account.external_id, opts)

    Enum.each(transactions_details, fn transaction_details -> sync_transaction(transaction_details, account) end)

    with %{"total_transactions" => total} when total > cursor <- response do
      sync_transactions(member, account, Keyword.merge(opts, offset: cursor))
    end
  end

  defp sync_transaction(details, account) do
    Repo.transaction(fn ->
      struct(BankTransaction)
      |> BankTransaction.changeset(Adapter.format(details, account.id, account.user_id, :bank_transaction))
      |> Repo.insert()
      |> case do
        {:ok, bank_transaction} ->
          struct(Transaction)
          |> Transaction.changeset(Adapter.format(bank_transaction, :transaction))
          |> Repo.insert!()

        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end
end
