defmodule Budget.Banks.Member do
  use Ecto.Schema
  import Ecto.Changeset

  alias Budget.Repo
  alias Budget.Banks.Providers.Plaid.Adapter

  schema "bank_members" do
    field :external_id, :string
    field :institution_id, :string
    field :logo, :string
    field :name, :string
    field :plaid_token, :string
    field :provider, :string
    field :status, :string

    belongs_to :user, Budget.User

    timestamps()
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:external_id, :institution_id, :logo, :name, :plaid_token, :provider, :status, :user_id])
    |> validate_required([:name, :user_id, :external_id, :provider])
  end

  def sync(user_id, external_id, token) do
    {:ok,
     %{
       body: details
     }} = Plaid.member(token)

    Repo.get_by(__MODULE__, user_id: user_id, external_id: external_id)
    |> case do
      nil -> %__MODULE__{plaid_token: token}
      model -> model
    end
    |> changeset(Adapter.format(details, user_id, :member))
  end
end
