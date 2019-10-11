defmodule Budget.Banks.Category do
  use Ecto.Schema

  schema "categories" do
    field :external_id, :string
    field :name, :string

    belongs_to :parent, __MODULE__

    timestamps()
  end
end
