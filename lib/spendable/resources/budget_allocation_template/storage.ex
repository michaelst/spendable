defmodule Spendable.BudgetAllocationTemplate.Storage do
  alias Spendable.Api
  alias Spendable.BudgetAllocationTemplate

  require Ash.Query

  def form_options(user_id) do
    BudgetAllocationTemplate
    |> Ash.Query.filter(user_id == ^user_id)
    |> Ash.Query.select([:id, :name])
    |> Ash.Query.sort([:name])
    |> Api.read!()
    |> Enum.map(&{&1.name, &1.id})
  end

  def get_template(id) do
    Spendable.Api.get!(BudgetAllocationTemplate, id, load: :budget_allocation_template_lines)
  end
end
