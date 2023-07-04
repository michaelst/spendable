defmodule Spendable.BankMember.Storage do
  alias Spendable.Api
  alias Spendable.BankMember

  require Ash.Query

  def list(user_id, opts \\ []) do
    BankMember
    |> Ash.Query.filter(user_id == ^user_id)
    |> maybe_search(opts[:search])
    |> Ash.Query.sort(:name)
    |> Api.read!()
  end

  defp maybe_search(query, search) when byte_size(search) > 0 do
    Ash.Query.filter(query, contains(name, ^search))
  end

  defp maybe_search(query, _search), do: query
end
