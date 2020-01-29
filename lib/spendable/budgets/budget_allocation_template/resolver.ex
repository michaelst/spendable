defmodule Spendable.Budgets.BudgetAllocationTemplate.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Budgets.BudgetAllocationTemplate
  alias Spendable.Repo

  def list(_parent, _args, %{context: %{current_user: user}}) do
    {:ok, from(BudgetAllocationTemplate, where: [user_id: ^user.id]) |> Repo.all()}
  end

  def create(params, %{context: %{current_user: user}}) do
    %BudgetAllocationTemplate{user_id: user.id}
    |> BudgetAllocationTemplate.changeset(params)
    |> Repo.insert()
  end

  def update(params, %{context: %{model: model}}) do
    model
    |> Repo.preload(:lines)
    |> BudgetAllocationTemplate.changeset(params)
    |> Repo.update()
  end
end
