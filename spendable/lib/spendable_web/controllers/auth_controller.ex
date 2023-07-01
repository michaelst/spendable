defmodule SpendableWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use SpendableWeb, :controller

  plug Ueberauth

  alias Coverbot.Resources.Account
  alias Coverbot.Resources.AccountUser
  alias Coverbot.Resources.User

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    %Ueberauth.Auth{
      uid: uid,
      provider: :github,
      info: %Ueberauth.Auth.Info{
        nickname: username,
        image: image
      }
    } = auth

    user =
      User
      |> Ash.Changeset.new(%{
        github_id: uid,
        github_username: username,
        github_avatar: image
      })
      |> Coverbot.Api.create!(upsert?: true, upsert_identity: :github_id)
      |> Coverbot.Api.load!(:accounts)
      |> maybe_create_account()

    conn
    |> put_session(:current_user_id, user.id)
    |> configure_session(renew: true)
    |> redirect(to: "/")
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: "/")
  end

  defp maybe_create_account(%{accounts: []} = user) do
    {:ok, %{body: %{"id" => stripe_customer_id}}} = Coverbot.Stripe.create_customer()

    account =
      Account
      |> Ash.Changeset.new(%{
        stripe_customer_id: stripe_customer_id
      })
      |> Ash.Changeset.manage_relationship(:users, [user], type: :append_and_remove)
      |> Coverbot.Api.create!()

    user = %{user | accounts: [account]}

    user
    |> Coverbot.Api.load!(:accounts_join_assoc)
    |> Map.get(:accounts_join_assoc)
    |> List.first()
    |> AccountUser.make_admin(true)

    user
  end

  defp maybe_create_account(user), do: user
end
