defmodule Spendable.TestUtils do
  import ExUnit.Assertions

  alias Spendable.Guardian
  alias Spendable.Repo
  alias Spendable.User

  def create_user do
    email = "#{Ecto.UUID.generate()}@example.com"
    user = %User{} |> User.changeset(%{email: email, password: "password"}) |> Repo.insert!()
    {:ok, token, _} = Guardian.encode_and_sign(user)

    {user, token}
  end

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
