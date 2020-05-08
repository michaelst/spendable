defmodule Spendable.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias Spendable.Repo

  schema "transactions" do
    field :amount, :decimal
    field :date, :date
    field :name, :string
    field :note, :string

    belongs_to :bank_transaction, Spendable.Banks.Transaction
    belongs_to :category, Spendable.Banks.Category
    belongs_to :user, Spendable.User

    has_many :allocations, Spendable.Budgets.Allocation, on_replace: :delete

    many_to_many :tags, Spendable.Tag, join_through: "transaction_tags", on_replace: :delete, unique: true

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __schema__(:fields) -- [:id])
    |> validate_required([:user_id, :amount, :date])
    |> cast_assoc(:allocations)
    |> maybe_put_tags(params)
  end

  defp maybe_put_tags(changeset, %{tag_ids: []}), do: put_assoc(changeset, :tags, [])

  defp maybe_put_tags(changeset, %{tag_ids: tag_ids}) when is_list(tag_ids) do
    put_assoc(changeset, :tags, Enum.map(tag_ids, &Repo.get!(Spendable.Tag, &1)))
  end

  defp maybe_put_tags(changeset, _params), do: changeset
end
