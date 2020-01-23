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

  def allocate(%{allocations: allocations}, %{context: %{current_user: user}}) do
    Repo.transaction(fn ->
      count =
        Enum.reduce(allocations, 0, fn %{amount: amount, budget_id: id}, acc ->
          {count, nil} = from(Budget, where: [id: ^id, user_id: ^user.id]) |> Repo.update_all(inc: [balance: amount])
          acc + count
        end)

      if count == length(allocations), do: count, else: Repo.rollback("update failed")
    end)
  end
end
