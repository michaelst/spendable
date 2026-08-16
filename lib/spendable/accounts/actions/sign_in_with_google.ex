defmodule Spendable.Accounts.Actions.SignInWithGoogle do
  @moduledoc false

  import Spendable.Accounts.Utils.VerifyIdToken

  alias Spendable.Accounts
  alias Spendable.Accounts.Clients.Google

  @issuers ["accounts.google.com", "https://accounts.google.com"]

  @doc """
  Verifies an ID token from a native sign-in, then returns the matching user, creating one on
  first sign-in.

  The subject is the same claim Ueberauth stores, so signing in on a phone lands on the account
  the browser already made. Keys are fetched per sign-in rather than cached: a device signs in
  once every ninety days, so a cache would save nothing and still have to handle Google rotating
  a key.
  """
  def sign_in_with_google(id_token) do
    with {:ok, %{body: certs}} <- Google.certs(),
         {:ok, claims} <-
           verify_id_token(id_token, certs, issuers: @issuers, audiences: audiences()) do
      Accounts.upsert_user_from_oauth(%{
        external_id: claims["sub"],
        provider: "google",
        email: claims["email"],
        image: claims["picture"]
      })
    end
  end

  defp audiences(), do: Application.get_env(:spendable, __MODULE__)[:audiences]
end
