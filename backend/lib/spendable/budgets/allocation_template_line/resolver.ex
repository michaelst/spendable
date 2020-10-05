defmodule Spendable.Budgets.AllocationTemplateLine.Resolver do
  alias Spendable.Budgets.AllocationTemplateLine
  alias Spendable.Repo

  def get(_args, %{context: %{model: model}}), do: {:ok, model}

  def create(params, %{context: %{current_user: user}}) do
    %AllocationTemplateLine{user: user}
    |> AllocationTemplateLine.changeset(params)
    |> Repo.insert()
  end

  def update(params, %{context: %{model: model}}) do
    model
    |> AllocationTemplateLine.changeset(params)
    |> Repo.update()
  end

  def delete(_params, %{context: %{model: model}}) do
    Repo.delete(model)
  end
end
