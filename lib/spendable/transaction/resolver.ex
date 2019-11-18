defmodule Spendable.Transaction.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Transaction
  alias Spendable.Repo

  def list(_parent, _args, %{context: %{current_user: user}}) do
    {:ok, from(Transaction, where: [user_id: ^user.id], order_by: [desc: :date], limit: 10) |> Repo.all()}
  end

  def update(params, %{context: %{model: model}}) do
    model
    |> Transaction.changeset(params)
    |> Repo.update()
  end
end
