defmodule Spendable.Transactions.Actions.MarkAsTransfer do
  @moduledoc false

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  @doc """
  Links two transactions as the two sides of a move between the user's own accounts.

  The pair has to be one transaction going out and one coming in, since a transfer moves money
  rather than spending it. Clearing their allocations parks the whole of each amount on
  Spendable, where the two opposite signs cancel, and both sides are marked reviewed because
  saying what a pair is leaves nothing else to decide about it.
  """
  def mark_as_transfer(
        %Scope{user: %{id: user_id}},
        %Transaction{user_id: user_id} = one,
        %Transaction{user_id: user_id} = two
      ) do
    with :ok <- validate_pair(one, two) do
      # Each side only points at a transaction the user already owns, so anything but success is
      # a database failure, and raising rolls both sides back.
      Repo.transaction(fn -> {link(one, two.id), link(two, one.id)} end)
    end
  end

  def mark_as_transfer(_scope, _one, _two), do: {:error, :not_authorized}

  defp validate_pair(%Transaction{id: id}, %Transaction{id: id}), do: {:error, :transfer_not_allowed}

  defp validate_pair(%Transaction{transfer_id: nil} = one, %Transaction{transfer_id: nil} = two) do
    if Decimal.negative?(one.amount) == Decimal.negative?(two.amount),
      do: {:error, :transfer_not_allowed},
      else: :ok
  end

  defp validate_pair(_one, _two), do: {:error, :already_transferred}

  defp link(transaction, transfer_id) do
    transaction
    |> Repo.preload(:budget_allocations)
    |> Transaction.changeset(%{
      "transfer_id" => transfer_id,
      "budget_allocations" => [],
      "reviewed" => true
    })
    |> Repo.update!()
    # The pair is what a row shows once it is one, and the side just linked was loaded as nothing
    # back when there was no transfer to load.
    |> Repo.preload([transfer: [bank_transaction: [bank_account: :bank_member]]], force: true)
  end
end
