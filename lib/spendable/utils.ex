defmodule Spendable.Utils do
  alias Spendable.Api
  alias Spendable.Budget
  alias Spendable.Repo

  def get_spendable_id(user) do
    budget =
      Repo.get_by(Budget, user_id: user.id, name: "Spendable")
      |> case do
        nil ->
          Budget
          |> Ash.Changeset.for_create(
            :create,
            %{
              name: "Spendable",
              track_spending_only: true
            },
            actor: user
          )
          |> Api.create!()

        budget ->
          budget
      end

    budget.id
  end

  def format_currency(decimal) do
    negative? = Decimal.negative?(decimal)

    string =
      decimal
      |> Decimal.abs()
      |> Decimal.round(2)
      |> Decimal.to_string()

    currency = if negative?, do: "-$", else: "$"

    formatted_dollars =
      string
      |> String.slice(0..-4//1)
      |> String.reverse()
      |> String.codepoints()
      |> Enum.chunk_every(3)
      |> Enum.join(",")
      |> String.reverse()

    decimals = String.slice(string, -3..-1)

    currency <> formatted_dollars <> decimals
  end
end
