defmodule Spendable.Transactions.Actions.UpdateTransaction do
  @moduledoc false

  import Spendable.Transactions.Utils.AllocateSpendable

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  def update_transaction(
        %Scope{user: %{id: user_id}} = scope,
        %Transaction{user_id: user_id} = transaction,
        attrs
      ) do
    Repo.transaction(fn ->
      transaction
      |> Repo.preload(:budget_allocations)
      |> Transaction.changeset(attrs)
      |> Repo.update()
      |> case do
        # The remainder is built from a valid transaction and the user's own Spendable budget, so
        # anything but an :ok is a database failure, and raising rolls the transaction back.
        {:ok, updated} ->
          {:ok, allocated} = allocate_spendable(scope, updated)
          allocated

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def update_transaction(_scope, _transaction, _attrs), do: {:error, :not_authorized}
end
