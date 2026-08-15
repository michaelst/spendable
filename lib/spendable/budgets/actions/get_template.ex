defmodule Spendable.Budgets.Actions.GetTemplate do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Budgets.Schemas.BudgetAllocationTemplate
  alias Spendable.Repo
  alias Spendable.Scope

  def get_template(%Scope{user: %{id: user_id}}, id) do
    query =
      from(template in BudgetAllocationTemplate,
        where: template.user_id == ^user_id,
        where: template.id == ^id,
        preload: [budget_allocation_template_lines: :budget]
      )

    case Repo.one(query) do
      %BudgetAllocationTemplate{} = template -> {:ok, template}
      nil -> {:error, :template_not_found}
    end
  end
end
