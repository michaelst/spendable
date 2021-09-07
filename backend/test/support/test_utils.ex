defmodule Spendable.TestUtils do
  import ExUnit.Assertions

  alias Ash.Changeset
  alias Spendable.Api
  alias Spendable.User

  def random_decimal(range, precision \\ 2) do
    Enum.random(range)
    |> Decimal.new()
    |> Decimal.div(100)
    |> Decimal.round(precision)
  end

  def assert_published(data) when is_list(data) do
    Enum.each(data, &assert_published/1)
  end

  def assert_published(%{__struct__: module} = data) do
    encoded_data = module.encode(data)
    assert_receive ^encoded_data, 1000
  end
end
