defmodule Spendable.Budgets.Actions.GetBudget do
  @moduledoc false

  import Ecto.Query
  import Spendable.Budgets.Utils.CalculateBalances

  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  def get_budget(%Scope{user: %{id: user_id}}, by) do
    query = from(budget in Budget, where: budget.user_id == ^user_id, where: ^by)

    case Repo.one(query) do
      %Budget{} = budget -> {:ok, calculate_balance(budget)}
      nil -> {:error, :budget_not_found}
    end
  end
end
