defmodule Spendable.Budgets.Actions.UpdateTemplate do
  @moduledoc false

  alias Spendable.Budgets.Schemas.BudgetAllocationTemplate
  alias Spendable.Repo
  alias Spendable.Scope

  def update_template(
        %Scope{user: %{id: user_id}},
        %BudgetAllocationTemplate{user_id: user_id} = template,
        attrs
      ) do
    template
    |> Repo.preload(:budget_allocation_template_lines)
    |> BudgetAllocationTemplate.changeset(attrs)
    |> Repo.update()
  end

  def update_template(_scope, _template, _attrs), do: {:error, :not_authorized}
end
