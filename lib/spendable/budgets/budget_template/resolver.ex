defmodule Spendable.Budgets.BudgetTemplate.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Budgets.BudgetTemplate
  alias Spendable.Repo

  def list(_parent, _args, %{context: %{current_user: user}}) do
    {:ok,
     from(BudgetTemplate, where: [user_id: ^user.id])
     |> Repo.all()}
  end

  def create(params, %{context: %{current_user: user}}) do
    %BudgetTemplate{user_id: user.id}
    |> BudgetTemplate.changeset(params)
    |> Repo.insert()
  end

  def update(params, %{context: %{model: model}}) do
    model
    |> Repo.preload(:lines)
    |> BudgetTemplate.changeset(params)
    |> Repo.update()
  end
end
