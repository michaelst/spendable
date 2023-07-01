defmodule Spendable.Budget.Storage do
  alias Spendable.Budget
  alias Spendable.Api

  require Ash.Query

  def list_budgets(user_id) do
    Budget
    |> Ash.Query.filter(user_id == ^user_id)
    |> Ash.Query.filter(is_nil(archived_at))
    |> Ash.Query.load(:balance)
    |> Ash.Query.after_action(fn _query, results ->
      {:ok,
       Enum.sort(results, fn a, b ->
         to_string(b.name) != "Spendable" and
           (to_string(a.name) == "Spendable" or a.name < b.name)
       end)}
    end)
    |> Api.read!()
  end
end
