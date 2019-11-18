defmodule Spendable.Banks.Category.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Banks.Category
  alias Spendable.Repo

  def list(_parent, _args, _resolution) do
    {:ok, from(Category, order_by: :name) |> Repo.all()}
  end
end
