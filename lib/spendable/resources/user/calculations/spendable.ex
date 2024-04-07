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
        where: ba.user_id == ^user.id,
        where: ba.sync,
        where: is_nil(ba.budget_id)
      )
      |> Repo.aggregate(:sum, :balance)
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
        left_join: ba in BankAccount,
        on: b.id == ba.budget_id,
        select: fragment("SUM(ABS(COALESCE(?, 0) + ?))", a.allocated, b.adjustment),
        where: b.user_id == ^user.id,
        # ignore budgets that are only used to track spending
        where: b.type != :tracking,
        # ignore budgets that are allocated from a bank account balance
        where: is_nil(ba.id)
      )
      |> Repo.one()
      |> Kernel.||("0.00")

    {:ok, [Decimal.sub(balance, allocated)]}
  end
end
