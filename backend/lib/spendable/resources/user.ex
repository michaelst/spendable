defmodule Spendable.User do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    repo(Spendable.Repo)
    table "users"
  end

  attributes do
    integer_primary_key :id

    attribute :bank_limit, :integer, default: 0, allow_nil?: false
    attribute :firebase_id, :string, allow_nil?: false
    # https://github.com/ash-project/ash/issues/217
    # attribute :firebase_id, :string, private?: true, allow_nil?: false

    timestamps()
  end

  identities do
    identity :firebase_id, [:firebase_id]
  end

  # relationships do
  #  has_many :notification_settings, Spendable.Notifications.Settings, destination_field: :user_id
  # end

  actions do
    read :current_user do
      filter [id: actor(:id)]
    end
  end
end
