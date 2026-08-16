defmodule Spendable.Budgets.Actions.CreateBudget do
  @moduledoc false

  import Spendable.Budgets.Utils.CalculateBalances

  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  The balance is filled in on the way out, the same as `update_budget/3` does, so a caller never
  reads a budget whose virtual balance is missing.
  """
  def create_budget(%Scope{user: %{id: user_id}}, attrs) do
    %Budget{user_id: user_id}
    |> Budget.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, budget} -> {:ok, calculate_balance(budget)}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
