defmodule Spendable.User.CalculateSpendable do
  use Ash.Calculation, type: :decimal

  import Ecto.Query

  alias Spendable.Banks.Account
  alias Spendable.Budgets.Allocation
  alias Spendable.Budgets.Budget
  alias Spendable.Repo

  @impl Ash.Calculation
  def calculate([user], _opts, _args) do
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
        full_join: b in Budget,
        on: a.budget_id == b.id,
        select: fragment("SUM(ABS(COALESCE(?, 0) + ?))", a.allocated, b.adjustment),
        where: b.user_id == ^user.id
      )
      |> Repo.one()
      |> Kernel.||("0.00")

    {:ok, [Decimal.sub(balance, allocated)]}
  end
end
