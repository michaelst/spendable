defmodule Spendable.Budgets.Actions.CreateBudget do
  @moduledoc false

  import Spendable.Budgets.Utils.CalculateBalances

  alias Spendable.Budgets
  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  The balance is filled in on the way out, the same as `update_budget/3` does, so a caller never
  reads a budget whose virtual balance is missing.

  A budget that funds itself is funded before that balance is read, so it appears holding its
  first month rather than empty until the nightly job comes round.
  """
  def create_budget(%Scope{user: %{id: user_id}} = scope, attrs) do
    %Budget{user_id: user_id}
    |> Budget.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, budget} ->
        funded = fund_this_month(budget, scope)

        {:ok, calculate_balance(funded)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  # Funding a month is idempotent, so this only ever fills what this month has not filled yet.
  defp fund_this_month(%Budget{funding_amount: nil} = budget, _scope), do: budget

  defp fund_this_month(%Budget{} = budget, scope) do
    {:ok, _funded} = Budgets.fund_budgets(scope, Date.utc_today())

    budget
  end
end
