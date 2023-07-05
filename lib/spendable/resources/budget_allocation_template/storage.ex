defmodule Spendable.BudgetAllocationTemplate.Storage do
  alias Spendable.Api
  alias Spendable.BudgetAllocationTemplate

  require Ash.Query

  def list(user_id, opts \\ []) do
    BudgetAllocationTemplate
    |> Ash.Query.filter(user_id == ^user_id)
    |> maybe_search(opts[:search])
    |> Ash.Query.sort([:name])
    |> Api.read!()
  end

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

  defp maybe_search(query, search) when byte_size(search) > 0 do
    Ash.Query.filter(query, contains(name, ^search))
  end

  defp maybe_search(query, _search), do: query
end
