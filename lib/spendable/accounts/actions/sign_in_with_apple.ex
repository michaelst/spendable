defmodule Spendable.Accounts.Actions.SignInWithApple do
  @moduledoc false

  import Spendable.Accounts.Utils.VerifyIdToken

  alias Spendable.Accounts
  alias Spendable.Accounts.Clients.Apple

  @issuers ["https://appleid.apple.com"]

  @doc """
  Verifies an ID token from Sign in with Apple, then returns the matching user.

  Apple sends no picture, and a user who chose Hide My Email arrives with a private relay address
  rather than their real one - that address is stable, so it still identifies them, but it will
  not match the email their Google sign-in recorded and the two accounts stay separate.
  """
  def sign_in_with_apple(id_token) do
    with {:ok, %{body: certs}} <- Apple.certs(),
         {:ok, claims} <-
           verify_id_token(id_token, certs, issuers: @issuers, audiences: audiences()) do
      Accounts.upsert_user_from_oauth(%{
        external_id: claims["sub"],
        provider: "apple",
        email: claims["email"]
      })
    end
  end

  defp audiences(), do: Application.get_env(:spendable, __MODULE__)[:audiences]
end
