defmodule Spendable.Transaction.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Transaction
  alias Spendable.Repo

  def list(_args, %{context: %{current_user: user}}) do
    {:ok, from(Transaction, where: [user_id: ^user.id], order_by: [desc: :date, desc: :id], limit: 100) |> Repo.all()}
  end

  def get(_args, %{context: %{model: model}}), do: {:ok, model}

  def update(args, %{context: %{model: model}}) do
    model
    |> Repo.preload(:allocations)
    |> Transaction.changeset(args)
    |> Repo.update()
  end
end
