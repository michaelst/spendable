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
        {:ok, transaction} -> unwrap(allocate_spendable(scope, transaction))
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  defp unwrap({:ok, transaction}), do: transaction
  defp unwrap({:error, changeset}), do: Repo.rollback(changeset)
end
