defmodule Spendable.TestUtils do
  import ExUnit.Assertions

  alias Spendable.User
  alias Spendable.Guardian
  alias Spendable.Repo

  def create_user() do
    email = "#{Ecto.UUID.generate()}@example.com"
    user = struct(User) |> User.changeset(%{email: email, password: "password"}) |> Repo.insert!()
    {:ok, token, _} = Guardian.encode_and_sign(user)

    {user, token}
  end

  def assert_job(module, args, opts \\ [queue: :default]) do
    {:ok, entries} = Exq.Api.jobs(Exq.Api, opts[:queue])
    "Elixir." <> module_str = "#{module}"

    assert Enum.any?(entries, fn
             %{class: ^module_str, args: ^args} -> true
             _ -> false
           end),
           "couldn't find #{module} with args #{inspect(args)}"
  end
end