defmodule Spendable.Transaction.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Repo
  alias Spendable.Transaction

  def list(args, %{context: %{current_user: user}}) do
    {:ok,
     from(Transaction,
       where: [user_id: ^user.id],
       order_by: [desc: :date, desc: :id],
       limit: 100,
       offset: ^args[:offset]
     )
     |> Repo.all()}
  end

  def get(_args, %{context: %{model: model}}), do: {:ok, model}

  def create(args, %{context: %{current_user: user}}) do
    %Transaction{user_id: user.id}
    |> Transaction.changeset(args)
    |> Repo.insert()
  end

  def update(args, %{context: %{model: model}}) do
    model
    |> Repo.preload([:allocations, :tags])
    |> Transaction.changeset(args)
    |> Repo.update()
  end

  def delete(_args, %{context: %{model: model}}) do
    Repo.delete(model)
  end
end
