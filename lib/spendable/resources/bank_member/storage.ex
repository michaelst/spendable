defmodule Spendable.BankMember.Storage do
  alias Spendable.Api
  alias Spendable.BankAccount
  alias Spendable.BankMember

  import Ecto.Query

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

  def available_balance(user_id) do
    query = from(b in BankAccount, where: b.user_id == ^user_id and b.sync)

    Spendable.Repo.aggregate(query, :sum, :balance)
  end

  def credit_card_balance(user_id) do
    query = from(b in BankAccount, where: b.user_id == ^user_id, where: b.sub_type == "credit card" and b.sync)

    Spendable.Repo.aggregate(query, :sum, :balance)
  end
end
