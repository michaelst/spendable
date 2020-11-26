defmodule Spendable.Budgets.Allocation.Resolver do
  alias Spendable.Budgets.Allocation
  alias Spendable.Repo

  def get(_args, %{context: %{model: model}}), do: {:ok, model}

  def create(params, %{context: %{current_user: user}}) do
    %Allocation{user: user}
    |> Allocation.changeset(params)
    |> Repo.insert()
  end

  def update(params, %{context: %{model: model}}) do
    model
    |> Allocation.changeset(params)
    |> Repo.update()
  end

  def delete(_params, %{context: %{model: model}}) do
    Repo.delete(model)
  end
end
