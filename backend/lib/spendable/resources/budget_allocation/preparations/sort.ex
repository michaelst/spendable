defmodule Spendable.BudgetAllocation.Preparations.Sort do
  use Ash.Resource.Preparation

  alias Spendable.Api

  @impl Ash.Resource.Preparation
  def prepare(query, _opts, _context) do
    Ash.Query.after_action(query, fn _query, results ->
      sorted_results =
        results
        |> Api.load!(:budget)
        |> Enum.sort(fn a, b ->
          b.budget.name != "Spendable" and (a.budget.name == "Spendable" or a.budget.name < b.budget.name)
        end)

      {:ok, sorted_results}
    end)
  end
end
