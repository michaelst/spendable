defmodule Spendable.Accounts.Actions.SignInWithOauth do
  @moduledoc false

  import Spendable.Accounts.Utils.VerifyProviderToken

  alias Spendable.Accounts

  @doc """
  Signs in from a native sign-in's ID token, creating an account if the subject is new.

  A subject the app has not seen is always a new account. Someone who already has one and wants
  to sign in this way instead links the provider from inside it, with `link_identity/3`.
  """
  def sign_in_with_oauth(provider, id_token) do
    with {:ok, %{external_id: external_id, image: image}} <-
           verify_provider_token(provider, id_token) do
      Accounts.upsert_user_from_oauth(%{
        external_id: external_id,
        provider: provider,
        image: image
      })
    end
  end
end
