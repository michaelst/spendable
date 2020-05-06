defmodule Spendable.Tag.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Repo
  alias Spendable.Tag

  def list(args, %{context: %{current_user: user}}) do
    {:ok,
     from(Tag,
       where: [user_id: ^user.id],
       order_by: :name
     )
     |> Repo.all()}
  end

  def create(args, %{context: %{current_user: user}}) do
    %Tag{user_id: user.id}
    |> Tag.changeset(args)
    |> Repo.insert()
  end

  def update(args, %{context: %{model: model}}) do
    model
    |> Tag.changeset(args)
    |> Repo.update()
  end

  def delete(_args, %{context: %{model: model}}) do
    Repo.delete(model)
  end
end
