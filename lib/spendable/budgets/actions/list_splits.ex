defmodule Spendable.Budgets.Actions.ListSplits do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Budgets.Schemas.Split
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  The lines come along because the caller that lists splits is usually about to apply one.
  """
  def list_splits(%Scope{user: %{id: user_id}}, opts \\ []) do
    from(split in Split,
      where: split.user_id == ^user_id,
      where: is_nil(split.archived_at),
      order_by: split.name,
      preload: :split_lines
    )
    |> maybe_search(opts[:search])
    |> Repo.all()
  end

  defp maybe_search(query, search) when is_binary(search) and byte_size(search) > 0 do
    where(query, [split], ilike(split.name, ^"%#{search}%"))
  end

  defp maybe_search(query, _search), do: query
end
