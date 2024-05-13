defmodule SpendableWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use SpendableWeb, :controller

  plug Ueberauth

  alias Spendable.User

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    %Ueberauth.Auth{
      uid: uid,
      provider: provider,
      info: %Ueberauth.Auth.Info{
        image: image
      }
    } = auth

    user =
      User
      |> Ash.Changeset.new(%{
        external_id: uid,
        provider: provider,
        image: image
      })
      |> Spendable.Api.create!(upsert?: true, upsert_identity: :external_id)

    conn
    |> put_session(:current_user_id, user.id)
    |> configure_session(renew: true)
    |> redirect(to: ~p"/budgets")
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: "/")
  end
end
