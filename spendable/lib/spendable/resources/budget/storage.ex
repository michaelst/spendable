defmodule Spendable.Budget.Storage do
  alias Spendable.Budget
  alias Spendable.Api

  require Ash.Query

  def list(user_id, opts \\ []) do
    Budget
    |> Ash.Query.filter(user_id == ^user_id)
    |> Ash.Query.filter(is_nil(archived_at))
    |> maybe_search_budgets(opts[:search])
    |> Ash.Query.load([
      :balance,
      spent: %{month: opts[:selected_month] || Date.utc_today()}
    ])
    |> Ash.Query.after_action(fn _query, results ->
      {:ok,
       Enum.sort(results, fn a, b ->
         to_string(b.name) != "Spendable" and
           (to_string(a.name) == "Spendable" or a.name < b.name)
       end)}
    end)
    |> Api.read!()
  end

  def form_options(user_id) do
    Budget
    |> Ash.Query.filter(user_id == ^user_id)
    |> Ash.Query.filter(is_nil(archived_at))
    |> Ash.Query.select([:id, :name])
    |> Ash.Query.after_action(fn _query, results ->
      {:ok,
       Enum.sort(results, fn a, b ->
         to_string(b.name) != "Spendable" and
           (to_string(a.name) == "Spendable" or a.name < b.name)
       end)}
    end)
    |> Api.read!()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp maybe_search_budgets(query, search) when byte_size(search) > 0 do
    Ash.Query.filter(query, contains(name, ^search))
  end

  defp maybe_search_budgets(query, _search), do: query
end
