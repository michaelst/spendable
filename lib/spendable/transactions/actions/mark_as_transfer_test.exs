defmodule Spendable.Transactions.Actions.MarkAsTransferTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Budgets
  alias Spendable.Scope
  alias Spendable.Transactions
  alias Spendable.Transactions.Schemas.Transaction

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, %{id: out_id} = out} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer to savings",
        "amount" => "-500.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    {:ok, %{id: in_id} = in_} =
      Transactions.create_transaction(scope, %{
        "name" => "Transfer from checking",
        "amount" => "500.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    %{scope: scope, out: out, out_id: out_id, in: in_, in_id: in_id}
  end

  test "links both sides of the transfer", %{
    scope: scope,
    out: out,
    out_id: out_id,
    in: in_,
    in_id: in_id
  } do
    assert {:ok, {%Transaction{}, %Transaction{}}} = Transactions.mark_as_transfer(scope, out, in_)

    assert {:ok, %Transaction{transfer_id: ^in_id}} =
             Transactions.get_transaction(scope, id: out_id)

    assert {:ok, %Transaction{transfer_id: ^out_id}} =
             Transactions.get_transaction(scope, id: in_id)
  end

  # A transfer moves money rather than spending it, so an envelope it was assigned to gets it back.
  test "moves the whole amount to Spendable", %{scope: scope, out: out, in: in_} do
    {:ok, budget} = Budgets.create_budget(scope, %{"name" => "Groceries"})

    {:ok, out} =
      Transactions.update_transaction(scope, out, %{
        "budget_allocations" => %{"0" => %{"amount" => "-500.00", "budget_id" => budget.id}}
      })

    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, in_)

    {:ok, %{id: spendable_id}} = Budgets.find_or_create_spendable_budget(scope)
    {:ok, out} = Transactions.get_transaction(scope, id: out.id)

    assert [%{budget_id: ^spendable_id, amount: amount}] = out.budget_allocations
    assert Decimal.eq?(amount, "-500.00")
  end

  test "rejects pairing a transaction with itself", %{scope: scope, out: out} do
    assert {:error, :transfer_not_allowed} = Transactions.mark_as_transfer(scope, out, out)
  end

  test "rejects two transactions moving the same way", %{scope: scope, out: out} do
    {:ok, other} =
      Transactions.create_transaction(scope, %{
        "name" => "Coffee",
        "amount" => "-5.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    assert {:error, :transfer_not_allowed} = Transactions.mark_as_transfer(scope, out, other)
  end

  test "rejects a transaction that is already part of a transfer", %{
    scope: scope,
    out: out,
    in: in_
  } do
    {:ok, _pair} = Transactions.mark_as_transfer(scope, out, in_)
    {:ok, out} = Transactions.get_transaction(scope, id: out.id)

    {:ok, other} =
      Transactions.create_transaction(scope, %{
        "name" => "Refund",
        "amount" => "500.00",
        "date" => "2026-08-15",
        "reviewed" => false
      })

    assert {:error, :already_transferred} = Transactions.mark_as_transfer(scope, out, other)
  end

  test "errors when the transactions belong to a different user", %{out: out, in: in_} do
    {:ok, other_user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert {:error, :not_authorized} =
             Transactions.mark_as_transfer(Scope.for_user(other_user), out, in_)
  end
end
