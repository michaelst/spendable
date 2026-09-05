defmodule Spendable.Budgets.Actions.FundBudgets do
  @moduledoc false

  import Ecto.Query
  import Spendable.Budgets.Utils.CalculateBalances

  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Budgets.Schemas.Funding
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Gives every budget that funds itself its monthly amount, and returns how many were funded.

  This is what replaces dividing a paycheck by hand: the user says once what a budget should hold
  each month, and the month fills it. Only a budget that keeps a balance can be funded - tracking
  and income record a month and hold nothing, so there is nowhere for the money to land.

  What a month puts in depends on whether the budget rolls over:

    * rolling over, it puts in the funding amount flat. An envelope 50 short starts the month at
      250 rather than 300, because the overspend is a real hole and carrying it is the point.
    * not rolling over, it puts in whatever brings the balance back to the funding amount. The
      same envelope gets 350 and starts whole, and one with 100 left over gets 200 rather than
      keeping it.

  Safe to run repeatedly. The unique index on the month is what makes that true, so a job that
  runs daily funds the month on its first run and does nothing on the rest.
  """
  def fund_budgets(%Scope{user: %{id: user_id}}, %Date{} = month) do
    month = Date.beginning_of_month(month)
    now = DateTime.utc_now()

    rows =
      from(budget in Budget,
        where: budget.user_id == ^user_id,
        where: budget.type in [:envelope, :goal],
        where: not is_nil(budget.funding_amount),
        where: is_nil(budget.archived_at)
      )
      |> Repo.all()
      |> calculate_balances()
      |> Enum.map(
        &%{
          id: UXID.generate!(prefix: "fnd"),
          amount: amount(&1),
          month: month,
          budget_id: &1.id,
          user_id: user_id,
          inserted_at: now,
          updated_at: now
        }
      )

    {funded, _returned} = Repo.insert_all(Funding, rows, on_conflict: :nothing)

    {:ok, funded}
  end

  defp amount(%Budget{rollover: true} = budget), do: budget.funding_amount

  # The balance already counts this month if it has been funded, which would make the top-up read
  # as zero - harmless, because the unique index drops the row before it is written.
  defp amount(%Budget{} = budget), do: Decimal.sub(budget.funding_amount, budget.balance)
end
