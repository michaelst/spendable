defmodule Spendable.User.Utils do
  import Ecto.Query, only: [from: 2, subquery: 1]

  alias Spendable.Banks.Account
  alias Spendable.Budgets.Allocation
  alias Spendable.Budgets.Budget
  alias Spendable.Repo

  def calculate_spendable(user) do
    balance =
      from(ba in Account,
        select:
          fragment(
            "SUM(CASE WHEN ? = 'credit' THEN -? ELSE COALESCE(?, ?) END)",
            ba.type,
            ba.balance,
            ba.available_balance,
            ba.balance
          ),
        where: ba.user_id == ^user.id and ba.sync
      )
      |> Repo.one()
      |> Kernel.||("0.00")

    allocations_query =
      from(a in Allocation,
        where: a.user_id == ^user.id,
        select: %{
          budget_id: a.budget_id,
          allocated: sum(a.amount)
        },
        group_by: a.budget_id
      )

    allocated =
      from(a in subquery(allocations_query),
        join: b in Budget,
        on: a.budget_id == b.id,
        select: fragment("SUM(ABS(? + ?))", a.allocated, b.adjustment)
      )
      |> Repo.one()
      |> Kernel.||("0.00")

    Decimal.sub(balance, allocated)
  end
end
