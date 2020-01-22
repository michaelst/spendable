defmodule Spendable.Budgets.Budget.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Budgets.Budget
  alias Spendable.Repo

  def list(_parent, _args, %{context: %{current_user: user}}) do
    {:ok, from(Budget, where: [user_id: ^user.id], order_by: [desc: :balance]) |> Repo.all()}
  end

  def create(params, %{context: %{current_user: user}}) do
    %Budget{user_id: user.id}
    |> Budget.changeset(params)
    |> Repo.insert()
  end

  def update(params, %{context: %{model: model}}) do
    model
    |> Budget.changeset(params)
    |> Repo.update()
  end
end
