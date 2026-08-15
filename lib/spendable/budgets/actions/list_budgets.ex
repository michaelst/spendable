defmodule Spendable.Budgets.Actions.ListBudgets do
  @moduledoc false

  import Ecto.Query
  import Spendable.Budgets.Utils.CalculateBalances

  alias Spendable.Budgets.Schemas.Budget
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Spendable sorts first because it is where unallocated money lands, so it is the one a user
  looks at most; the rest are alphabetical.

  Spending is left for `calculate_spent/3`: it is per-month, and most callers want a list of
  budgets rather than a month's worth of activity.
  """
  def list_budgets(%Scope{user: %{id: user_id}}, opts \\ []) do
    from(budget in Budget,
      where: budget.user_id == ^user_id,
      where: is_nil(budget.archived_at)
    )
    |> maybe_search(opts[:search])
    |> Repo.all()
    |> calculate_balances()
    |> Enum.sort_by(&{&1.name != "Spendable", &1.name})
  end

  defp maybe_search(query, search) when is_binary(search) and byte_size(search) > 0 do
    where(query, [budget], ilike(budget.name, ^"%#{search}%"))
  end

  defp maybe_search(query, _search), do: query
end
