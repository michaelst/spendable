defmodule Spendable.User.Calculations.Spendable do
  use Ash.Calculation, type: :decimal

  import Ecto.Query

  alias Spendable.BankAccount
  alias Spendable.Budget
  alias Spendable.BudgetAllocation
  alias Spendable.Repo

  @impl Ash.Calculation
  def calculate([user], _opts, _resolution) do
    balance =
      from(ba in BankAccount,
        select:
          fragment(
            "SUM(CASE WHEN ? = 'credit' THEN -? ELSE ? END)",
            ba.type,
            ba.balance,
            ba.balance
          ),
        where: ba.user_id == ^user.id and ba.sync
      )
      |> Repo.one()
      |> Kernel.||("0.00")

    allocations_query =
      from(a in BudgetAllocation,
        where: a.user_id == ^user.id,
        select: %{
          budget_id: a.budget_id,
          allocated: sum(a.amount)
        },
        group_by: a.budget_id
      )

    allocated =
      from(a in subquery(allocations_query),
        full_join: b in Budget,
        on: a.budget_id == b.id,
        select: fragment("SUM(ABS(COALESCE(?, 0) + ?))", a.allocated, b.adjustment),
        where: b.user_id == ^user.id,
        # ignore budgets that are only used to track spending
        where: b.track_spending_only == false
      )
      |> Repo.one()
      |> Kernel.||("0.00")

    {:ok, [Decimal.sub(balance, allocated)]}
  end
end
