defmodule Spendable.Budgets.Actions.FindOrCreateSpendableBudget do
  @moduledoc false

  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  @spendable_name "Spendable"

  @doc """
  The budget that absorbs whatever a transaction does not allocate elsewhere.

  It is created on first use rather than at signup, so an account that predates it still gets one.
  It tracks rather than budgets: it is a remainder, not a target.
  """
  def find_or_create_spendable_budget(%Scope{user: %{id: user_id}} = scope) do
    case Repo.get_by(Budget, user_id: user_id, name: @spendable_name) do
      %Budget{} = budget ->
        {:ok, budget}

      nil ->
        %Budget{user_id: scope.user.id}
        |> Budget.changeset(%{name: @spendable_name, type: :tracking})
        |> Repo.insert()
    end
  end
end
