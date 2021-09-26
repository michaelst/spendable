defmodule Spendable.User.SpentByMonth do
  use Ash.Resource,
    data_layer: :embedded,
    extensions: [AshGraphql.Resource]

  graphql do
    type :month_spend
  end

  attributes do
    attribute :month, :string, allow_nil?: false
    attribute :spent, :decimal, allow_nil?: false
  end
end