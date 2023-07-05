defmodule Spendable.Transaction.Storage do
  alias Spendable.Api
  alias Spendable.Transaction

  require Ash.Query

  @default_per_page 25

  def list_transactions(user_id, opts \\ []) do
    Transaction
    |> Ash.Query.filter(user_id == ^user_id)
    |> maybe_search_transactions(opts[:search])
    |> Ash.Query.sort(date: :desc, id: :desc)
    |> maybe_paginate(opts[:page], opts[:per_page])
    |> Ash.Query.limit(opts[:per_page] || @default_per_page)
    |> Api.read!()
  end

  defp maybe_search_transactions(query, search) when byte_size(search) > 0 do
    Ash.Query.filter(query, contains(name, ^search) or contains(note, ^search))
  end

  defp maybe_search_transactions(query, _search), do: query

  defp maybe_paginate(query, page, limit) when page > 0 do
    limit = limit || @default_per_page
    offset = (page - 1) * limit
    Ash.Query.offset(query, offset)
  end

  defp maybe_paginate(query, _page, _limit), do: query
end
