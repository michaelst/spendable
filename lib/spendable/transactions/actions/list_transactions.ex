defmodule Spendable.Transactions.Actions.ListTransactions do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  @default_per_page 25

  @doc """
  Newest first, with the id breaking ties so paging stays stable across same-day transactions.

  Reviewed and excluded transactions are hidden unless asked for: the list is a queue of what
  still needs attention.

  A transfer is one movement of money, so the list carries the side that left and preloads the
  side it arrived in. Nothing is hidden until the two are paired, which is what an unreviewed
  arrival still being listed depends on.
  """
  def list_transactions(%Scope{user: %{id: user_id}}, opts \\ []) do
    per_page = opts[:per_page] || @default_per_page

    from(transaction in Transaction,
      where: transaction.user_id == ^user_id,
      where: is_nil(transaction.transfer_id) or transaction.amount < 0,
      order_by: [desc: transaction.date, desc: transaction.id],
      limit: ^per_page,
      preload: [
        :budget_allocations,
        bank_transaction: [bank_account: :bank_member],
        transfer: [bank_transaction: [bank_account: :bank_member]]
      ]
    )
    |> maybe_hide_reviewed(opts[:show_reviewed])
    |> maybe_hide_excluded(opts[:show_excluded])
    |> maybe_search(opts[:search])
    |> maybe_paginate(opts[:page], per_page)
    |> Repo.all()
  end

  defp maybe_hide_reviewed(query, true = _show_reviewed), do: query
  defp maybe_hide_reviewed(query, _show_reviewed), do: where(query, [t], t.reviewed == false)

  defp maybe_hide_excluded(query, true = _show_excluded), do: query
  defp maybe_hide_excluded(query, _show_excluded), do: where(query, [t], t.excluded == false)

  defp maybe_search(query, search) when is_binary(search) and byte_size(search) > 0 do
    pattern = "%#{search}%"

    where(query, [t], ilike(t.name, ^pattern) or ilike(t.note, ^pattern))
  end

  defp maybe_search(query, _search), do: query

  defp maybe_paginate(query, page, per_page) when is_integer(page) and page > 1 do
    offset(query, ^((page - 1) * per_page))
  end

  defp maybe_paginate(query, _page, _per_page), do: query
end
