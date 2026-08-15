defmodule SpendableWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use SpendableWeb, :controller

  plug Ueberauth

  alias Spendable.Accounts

  def login(conn, _params) do
    render(conn, :login, layout: false)
  end

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

    # Ueberauth hands the provider back as an atom; the boundary is where that becomes our string.
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{
        external_id: uid,
        provider: to_string(provider),
        image: image
      })

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
