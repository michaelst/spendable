defmodule Spendable.Budget.SpentByMonth do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute :month, :date, allow_nil?: false
    attribute :spent, :decimal, allow_nil?: false
  end
end
