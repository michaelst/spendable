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
end
