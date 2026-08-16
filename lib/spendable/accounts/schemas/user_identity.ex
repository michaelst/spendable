defmodule Spendable.Accounts.Schemas.UserIdentity do
  @moduledoc false
  use Spendable.Schema

  alias Spendable.Accounts.Schemas.User

  @primary_key {:id, UXID, autogenerate: true, prefix: "usi"}
  schema "user_identities" do
    field :provider, :string
    field :external_id, :string

    belongs_to :user, User

    timestamps()
  end

  # No changeset: nothing here is user-defined. The provider and its subject come from a verified
  # ID token or from Ueberauth, and are set on the struct the way user_id is everywhere else.
end
