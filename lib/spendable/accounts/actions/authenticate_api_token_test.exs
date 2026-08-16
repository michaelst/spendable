defmodule Spendable.Accounts.Actions.AuthenticateApiTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Accounts.Schemas.User
  alias Spendable.Scope

  setup do
    {:ok, %User{id: user_id} = user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, api_token} = Accounts.create_api_token(Scope.for_user(user), %{})

    %{user_id: user_id, api_token: api_token}
  end

  test "returns the token with its user preloaded", %{user_id: user_id, api_token: api_token} do
    assert {:ok, %ApiToken{user: %User{id: ^user_id}}} =
             Accounts.authenticate_api_token(api_token.token)
  end

  test "errors on an unknown token" do
    assert {:error, :invalid_token} = Accounts.authenticate_api_token("nope")
  end

  test "errors when no token is given" do
    assert {:error, :invalid_token} = Accounts.authenticate_api_token(nil)
  end

  test "errors on an expired token", %{api_token: api_token} do
    expired = DateTime.add(DateTime.utc_now(), -1, :day)
    {:ok, _aged} = api_token |> Ecto.Changeset.change(%{expires_at: expired}) |> Repo.update()

    assert {:error, :invalid_token} = Accounts.authenticate_api_token(api_token.token)
  end

  test "slides expiry forward for a token last used over a day ago", %{api_token: api_token} do
    yesterday = DateTime.add(DateTime.utc_now(), -2, :day)
    {:ok, aged} = api_token |> Ecto.Changeset.change(%{last_used_at: yesterday}) |> Repo.update()

    {:ok, authenticated} = Accounts.authenticate_api_token(api_token.token)

    assert DateTime.after?(authenticated.expires_at, aged.expires_at)
    assert DateTime.after?(authenticated.last_used_at, aged.last_used_at)
  end

  test "leaves a token used within the day alone", %{api_token: api_token} do
    {:ok, authenticated} = Accounts.authenticate_api_token(api_token.token)

    assert authenticated.last_used_at == api_token.last_used_at
  end
end
