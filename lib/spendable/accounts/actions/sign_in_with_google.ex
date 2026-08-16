defmodule Spendable.Accounts.Actions.SignInWithGoogle do
  @moduledoc false

  alias Spendable.Accounts
  alias Spendable.Accounts.Clients.Google

  @issuers ["accounts.google.com", "https://accounts.google.com"]

  @doc """
  Verifies an ID token from a native sign-in against Google's published keys, then returns the
  matching user, creating one on first sign-in.

  The subject is the same claim Ueberauth stores as `external_id`, so signing in on a phone lands
  on the account the browser already made. Keys are fetched per sign-in rather than cached: a
  device signs in once every ninety days, so a cache would save nothing and still have to handle
  Google rotating a key.
  """
  def sign_in_with_google(id_token) when is_binary(id_token) do
    with {:ok, %{"kid" => kid}} <- Joken.peek_header(id_token),
         {:ok, jwk} <- fetch_key(kid),
         {:ok, claims} <- Joken.verify(id_token, Joken.Signer.create("RS256", jwk)),
         :ok <- validate_claims(claims) do
      Accounts.upsert_user_from_oauth(%{
        external_id: claims["sub"],
        provider: "google",
        image: claims["picture"]
      })
    else
      _invalid -> {:error, :invalid_id_token}
    end
  end

  def sign_in_with_google(_id_token), do: {:error, :invalid_id_token}

  defp fetch_key(kid) do
    with {:ok, %{body: %{"keys" => keys}}} <- Google.certs(),
         %{} = jwk <- Enum.find(keys, &(&1["kid"] == kid)) do
      {:ok, jwk}
    else
      _no_matching_key -> {:error, :invalid_id_token}
    end
  end

  defp validate_claims(%{"iss" => iss, "aud" => aud, "exp" => exp, "sub" => sub})
       when is_binary(sub) do
    cond do
      iss not in @issuers -> {:error, :invalid_id_token}
      aud not in audiences() -> {:error, :invalid_id_token}
      exp <= DateTime.to_unix(DateTime.utc_now()) -> {:error, :invalid_id_token}
      true -> :ok
    end
  end

  defp validate_claims(_claims), do: {:error, :invalid_id_token}

  defp audiences(), do: Application.get_env(:spendable, __MODULE__)[:audiences]
end
