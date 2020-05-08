defmodule Spendable.Banks.Category.Resolver do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Banks.Category
  alias Spendable.Repo

  def list(_parent, _args, _resolution) do
    {:ok, from(c in Category, order_by: fragment("lower(?)", c.name)) |> Repo.all()}
  end
end
