defmodule Spendable.Jobs.Banks.SyncMember do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Banks.Account
  alias Spendable.Banks.Member
  alias Spendable.Banks.Providers.Plaid.Adapter
  alias Spendable.Banks.Transaction, as: BankTransaction
  alias Spendable.Repo
  alias Spendable.Transaction

  def perform(member_id) do
    Repo.get!(Member, member_id)
    |> sync_member()
    |> sync_accounts()
    |> Enum.filter(& &1.sync)
    |> Enum.each(&sync_transactions/1)
  end

  defp sync_member(member) do
    {:ok, %{body: details}} = Plaid.item(member.plaid_token)

    member
    |> Member.changeset(Adapter.format(details, member.user_id, :member))
    |> Repo.update!()
  end

  defp sync_accounts(member) do
    {:ok, %{body: %{"accounts" => accounts_details}}} = Plaid.accounts(member.plaid_token)

    Enum.map(accounts_details, fn account_details ->
      Repo.get_by(Account, user_id: member.user_id, external_id: account_details["account_id"])
      |> case do
        nil -> struct(Account)
        account -> account
      end
      |> Account.changeset(Adapter.format(account_details, member.id, member.user_id, :account))
      |> Repo.insert_or_update!()
      |> Map.put(:bank_member, member)
    end)
  end

  defp sync_transactions(account, opts \\ []) do
    count = opts[:count] || 500
    offset = opts[:offset] || 0
    cursor = offset + count

    {:ok, %{body: %{"transactions" => transactions_details} = response}} =
      Plaid.account_transactions(account.bank_member.plaid_token, account.external_id, opts)

    Enum.each(transactions_details, fn transaction_details -> sync_transaction(transaction_details, account) end)

    with %{"total_transactions" => total} when total > cursor <- response do
      sync_transactions(account, Keyword.merge(opts, offset: cursor))
    end
  end

  defp sync_transaction(details, account) do
    Repo.transaction(fn ->
      %BankTransaction{}
      |> BankTransaction.changeset(Adapter.format(details, account.id, account.user_id, :bank_transaction))
      |> Repo.insert()
      |> case do
        {:ok, bank_transaction} ->
          %Transaction{}
          |> Transaction.changeset(Adapter.format(bank_transaction, :transaction))
          |> Repo.insert!()
          |> reassign_pending(details)

        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  defp reassign_pending(transaction, %{"pending_transaction_id" => pending_id}) when is_binary(pending_id) do
    Repo.get_by(BankTransaction, external_id: pending_id, pending: true)
    |> Repo.preload(:transaction)
    |> case do
      nil ->
        transaction

      pending_bank_transaction ->
        from(Spendable.Budgets.Allocation, where: [transaction_id: ^pending_bank_transaction.transaction.id])
        |> Repo.update_all(set: [transaction_id: transaction.id])

        Repo.delete!(pending_bank_transaction.transaction)
        Repo.delete!(pending_bank_transaction)

        transaction
    end
  end

  defp reassign_pending(transaction, _), do: transaction
end
