defmodule Spendable.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string

    belongs_to :user, Spendable.User

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __schema__(:fields) -- [:id])
    |> validate_required([:name, :user_id])
    |> unique_constraint(:name, name: :tags_user_id_name_index)
  end
end
