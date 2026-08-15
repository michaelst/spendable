defmodule Spendable.Budgets.Actions.CreateBudget do
  @moduledoc false

  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  def create_budget(%Scope{user: %{id: user_id}}, attrs) do
    %Budget{user_id: user_id}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end
end
