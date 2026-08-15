defmodule Spendable.Budgets.Actions.CreateTemplate do
  @moduledoc false

  alias Spendable.Budgets.Schemas.BudgetAllocationTemplate
  alias Spendable.Repo
  alias Spendable.Scope

  def create_template(%Scope{user: %{id: user_id}}, attrs) do
    %BudgetAllocationTemplate{user_id: user_id}
    |> BudgetAllocationTemplate.changeset(attrs)
    |> Repo.insert()
  end
end
