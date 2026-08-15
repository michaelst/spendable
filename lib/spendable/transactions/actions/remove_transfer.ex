defmodule Spendable.Transactions.Actions.RemoveTransfer do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  @doc """
  Unlinks both sides of a transfer, so the two transactions count toward budgets again.

  Their allocations are left where they are: whatever the transfer parked on Spendable is still
  the right home for money the user has not assigned.
  """
  def remove_transfer(
        %Scope{user: %{id: user_id}},
        %Transaction{user_id: user_id, transfer_id: transfer_id} = transaction
      )
      when is_binary(transfer_id) do
    ids = [transaction.id, transfer_id]

    {_count, _returned} =
      from(record in Transaction,
        where: record.user_id == ^user_id,
        where: record.id in ^ids
      )
      |> Repo.update_all(set: [transfer_id: nil, updated_at: DateTime.utc_now()])

    {:ok, %{transaction | transfer_id: nil, transfer: nil}}
  end

  def remove_transfer(%Scope{user: %{id: user_id}}, %Transaction{user_id: user_id}) do
    {:error, :not_a_transfer}
  end

  def remove_transfer(_scope, _transaction), do: {:error, :not_authorized}
end
