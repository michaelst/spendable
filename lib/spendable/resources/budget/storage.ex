defmodule Spendable.Budget.Storage do
  alias Spendable.Api
  alias Spendable.Budget

  require Ash.Query

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
end
