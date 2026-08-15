defmodule Spendable.Transactions.Actions.CreateTransaction do
  @moduledoc false

  import Spendable.Transactions.Utils.AllocateSpendable

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  @doc "The insert and the remainder allocation are one unit, so a failure leaves nothing behind."
  def create_transaction(%Scope{user: %{id: user_id}} = scope, attrs) do
    Repo.transaction(fn ->
      %Transaction{user_id: user_id}
      |> Transaction.changeset(attrs)
      |> Repo.insert()
      |> case do
        # The remainder is built from a valid transaction and the user's own Spendable budget, so
        # anything but an :ok is a database failure, and raising rolls the transaction back.
        {:ok, transaction} ->
          {:ok, allocated} = allocate_spendable(scope, transaction)
          allocated

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end
end
