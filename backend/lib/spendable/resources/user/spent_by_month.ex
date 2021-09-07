defmodule Spendable.User.SpentByMonth do
  use Ash.Resource,
    data_layer: :embedded,
    extensions: [AshGraphql.Resource]

  graphql do
    type :spent_by_month
  end

  attributes do
    attribute :month, :string, allow_nil?: false
    attribute :spent, :decimal, allow_nil?: false
  end
end
