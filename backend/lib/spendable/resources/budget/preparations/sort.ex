defmodule Spendable.Budget.Preparations.Sort do
  use Ash.Resource.Preparation

  @impl Ash.Resource.Preparation
  def prepare(query, _opts, _context) do
    query
    |> Ash.Query.select(:name)
    |> Ash.Query.after_action(fn _query, results ->
      {:ok,
       Enum.sort(results, fn a, b ->
         b.name != "Spendable" and (a.name == "Spendable" or a.name < b.name)
       end)}
    end)
  end
end
