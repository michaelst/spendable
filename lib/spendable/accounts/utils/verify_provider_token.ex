defmodule Spendable.Accounts.Utils.VerifyProviderToken do
  @moduledoc "Import this module rather than aliasing it."

  alias Spendable.Accounts.Clients.Apple
  alias Spendable.Accounts.Clients.Google

  @providers %{
    "apple" => %{client: Apple, issuers: ["https://appleid.apple.com"]},
    "google" => %{
      client: Google,
      issuers: ["accounts.google.com", "https://accounts.google.com"]
    }
  }

  @doc """
  Checks an ID token from a native sign-in against the keys its provider publishes, and returns
  the subject it identifies.

  Google and Apple both hand the app one of these, and what makes it safe is the same either way:
  the signature has to match a published key, and the token has to have been minted by the
  provider we expect, for this app, and not yet have expired. Keys are fetched per call rather
  than cached - signing in is rare, so a cache would save nothing and still have to cope with a
  provider rotating a key.
  """
  def verify_provider_token(provider, id_token)
      when is_map_key(@providers, provider) and is_binary(id_token) do
    %{client: client, issuers: issuers} = @providers[provider]

    with {:ok, %{body: certs}} <- client.certs(),
         {:ok, %{"kid" => kid}} <- Joken.peek_header(id_token),
         %{} = jwk <- find_key(certs, kid),
         {:ok, claims} <- Joken.verify(id_token, Joken.Signer.create("RS256", jwk)),
         :ok <- validate_claims(claims, issuers, audiences(client)) do
      {:ok, %{external_id: claims["sub"], image: claims["picture"]}}
    else
      _invalid -> {:error, :invalid_id_token}
    end
  end

  def verify_provider_token(_provider, _id_token), do: {:error, :invalid_id_token}

  defp find_key(%{"keys" => keys}, kid), do: Enum.find(keys, &(&1["kid"] == kid))
  defp find_key(_certs, _kid), do: nil

  defp validate_claims(%{"iss" => iss, "aud" => aud, "exp" => exp, "sub" => sub}, issuers, audiences)
       when is_binary(sub) do
    cond do
      iss not in issuers -> {:error, :invalid_id_token}
      aud not in audiences -> {:error, :invalid_id_token}
      exp <= DateTime.to_unix(DateTime.utc_now()) -> {:error, :invalid_id_token}
      true -> :ok
    end
  end

  defp validate_claims(_claims, _issuers, _audiences), do: {:error, :invalid_id_token}

  defp audiences(client), do: Application.get_env(:spendable, client)[:audiences]
end
