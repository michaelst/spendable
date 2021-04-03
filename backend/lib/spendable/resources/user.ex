defmodule Spendable.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  postgres do
    repo(Spendable.Repo)
    table "users"
  end

  attributes do
    integer_primary_key :id

    attribute :bank_limit, :integer, default: 0, allow_nil?: false
    attribute :firebase_id, :string, private?: true, allow_nil?: false

    timestamps()
  end

  identities do
    identity :firebase_id, [:firebase_id]
  end

  # relationships do
  #  has_many :notification_settings, Spendable.Notifications.Settings, destination_field: :user_id
  # end

  calculations do
    calculate :spendable, :decimal, Spendable.User.CalculateSpendable
  end

  actions do
    # TODO: need to remove id requirement
    read :current_user do
      filter id: actor(:id)
    end
  end

  graphql do
    type :post

    queries do
      get :current_user, :current_user
    end
  end
end
