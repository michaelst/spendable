defmodule Spendable.Banks.Actions.IngestBankTransactions do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankTransaction
  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions

  @doc """
  Records activity against an account and gives the user a transaction for each entry that is new.

  Entries arrive already normalised, so this is the one path every source shares. Returns how many
  were new: a source replaying activity we already hold is the normal case, not a failure.

  An entry may name the pending entry it settles, in `replaces`.
  """
  def ingest_bank_transactions(
        %Scope{user: %{id: user_id}} = scope,
        %BankAccount{user_id: user_id} = bank_account,
        entries
      ) do
    ingested =
      Enum.count(entries, fn entry ->
        {replaces, attrs} = Map.pop(entry, :replaces)

        %BankTransaction{user_id: user_id, bank_account_id: bank_account.id}
        |> BankTransaction.changeset(attrs)
        # A duplicate is the normal case, so it rolls back to a savepoint. Without one it would
        # abort an enclosing transaction and take the rest of the batch with it.
        |> Repo.insert(mode: :savepoint)
        |> case do
          {:ok, bank_transaction} ->
            create_transaction(bank_transaction, replaces, scope)
            true

          {:error, _already_ingested} ->
            false
        end
      end)

    {:ok, ingested}
  end

  def ingest_bank_transactions(_scope, _bank_account, _entries), do: {:error, :not_authorized}

  defp create_transaction(bank_transaction, replaces, scope) do
    {:ok, transaction} =
      Transactions.create_transaction(scope, %{
        "amount" => bank_transaction.amount,
        "date" => bank_transaction.date,
        "name" => bank_transaction.name,
        "reviewed" => false,
        "bank_transaction_id" => bank_transaction.id
      })

    replace_pending(transaction, replaces, scope)
  end

  # A pending transaction is replaced by a settled one under a new id. The user may already have
  # allocated the pending one, so its allocations move across rather than being asked for twice.
  defp replace_pending(transaction, replaces, scope) when is_binary(replaces) do
    query =
      from(bank_transaction in BankTransaction,
        where: bank_transaction.user_id == ^scope.user.id,
        where: bank_transaction.external_id == ^replaces,
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

  defp replace_pending(_transaction, _replaces, _scope), do: :ok
end
