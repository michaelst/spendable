defmodule Spendable.Banks.Category do
  use Ecto.Schema

  schema "categories" do
    field :external_id, :string
    field :name, :string
    field :parent_name, :string

    belongs_to :parent, __MODULE__
  end
end
