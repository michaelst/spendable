defmodule Spendable.Accounts.Utils.VerifyIdToken do
  @moduledoc "Import this module rather than aliasing it."

  @doc """
  Checks an OpenID Connect ID token against the keys its issuer publishes.

  Google and Apple both hand a native sign-in one of these, and the checks that make it safe are
  the same either way: the signature has to match a published key, and the token has to have been
  minted by the issuer we expect, for this app, and not yet have expired.
  """
  def verify_id_token(id_token, certs, opts) when is_binary(id_token) do
    with {:ok, %{"kid" => kid}} <- Joken.peek_header(id_token),
         %{} = jwk <- find_key(certs, kid),
         {:ok, claims} <- Joken.verify(id_token, Joken.Signer.create("RS256", jwk)),
         :ok <- validate_claims(claims, opts) do
      {:ok, claims}
    else
      _invalid -> {:error, :invalid_id_token}
    end
  end

  def verify_id_token(_id_token, _certs, _opts), do: {:error, :invalid_id_token}

  defp find_key(%{"keys" => keys}, kid), do: Enum.find(keys, &(&1["kid"] == kid))
  defp find_key(_certs, _kid), do: nil

  defp validate_claims(%{"iss" => iss, "aud" => aud, "exp" => exp, "sub" => sub}, opts)
       when is_binary(sub) do
    cond do
      iss not in opts[:issuers] -> {:error, :invalid_id_token}
      aud not in opts[:audiences] -> {:error, :invalid_id_token}
      exp <= DateTime.to_unix(DateTime.utc_now()) -> {:error, :invalid_id_token}
      true -> :ok
    end
  end

  defp validate_claims(_claims, _opts), do: {:error, :invalid_id_token}
end
