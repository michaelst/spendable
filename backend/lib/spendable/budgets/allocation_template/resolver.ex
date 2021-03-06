defmodule Spendable.Budgets.AllocationTemplate.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Budgets.AllocationTemplate
  alias Spendable.Repo

  def list(_args, %{context: %{current_user: user}}) do
    {:ok, from(AllocationTemplate, where: [user_id: ^user.id], order_by: :id) |> Repo.all()}
  end

  def get(_args, %{context: %{model: model}}), do: {:ok, model}

  def create(params, %{context: %{current_user: user}}) do
    %AllocationTemplate{user_id: user.id}
    |> AllocationTemplate.changeset(params)
    |> Repo.insert()
  end

  def update(params, %{context: %{model: model}}) do
    model
    |> Repo.preload(:lines)
    |> AllocationTemplate.changeset(params)
    |> Repo.update()
  end

  def delete(_params, %{context: %{model: model}}) do
    Repo.delete(model)
  end
end
