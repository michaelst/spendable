defmodule Spendable.Transaction.Storage do
  alias Spendable.Api
  alias Spendable.Transaction

  require Ash.Query

  def list_transactions(user_id, opts \\ []) do
    Transaction
    |> Ash.Query.filter(user_id == ^user_id)
    |> maybe_search_transactions(opts[:search])
    |> Ash.Query.sort(date: :desc)
    |> Ash.Query.limit(100)
    |> Api.read!()
  end

  defp maybe_search_transactions(query, search) when byte_size(search) > 0 do
    Ash.Query.filter(query, contains(name, ^search) or contains(note, ^search))
  end

  defp maybe_search_transactions(query, _search), do: query
end
