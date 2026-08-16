defmodule Spendable.TestData.Google do
  @moduledoc """
  A throwaway RSA keypair standing in for Google's, so tests can sign an ID token the real
  verification path accepts. Generated once at compile time - generating per test costs more than
  the tests do.
  """

  @kid "test-key"
  @audience "spendable-ios.apps.googleusercontent.com"

  @keypair JOSE.JWK.generate_key({:rsa, 2048})
  @private_key @keypair |> JOSE.JWK.to_map() |> elem(1)
  @public_key @keypair |> JOSE.JWK.to_public_map() |> elem(1)

  @doc "The JWKS document Google serves at /oauth2/v3/certs."
  def certs(), do: %{"keys" => [Map.put(@public_key, "kid", @kid)]}

  @doc "An ID token signed by the key `certs/0` publishes. Pass claims to override the defaults."
  def id_token(claims \\ %{}) do
    signer = Joken.Signer.create("RS256", @private_key, %{"kid" => @kid})

    Joken.generate_and_sign!(%{}, Map.merge(default_claims(), claims), signer)
  end

  @doc "An ID token signed by a key Google does not publish."
  def id_token_from_unknown_key() do
    other_key = {:rsa, 2048} |> JOSE.JWK.generate_key() |> JOSE.JWK.to_map() |> elem(1)
    signer = Joken.Signer.create("RS256", other_key, %{"kid" => @kid})

    Joken.generate_and_sign!(%{}, default_claims(), signer)
  end

  defp default_claims() do
    %{
      "aud" => @audience,
      "exp" => DateTime.utc_now() |> DateTime.add(1, :hour) |> DateTime.to_unix(),
      "iss" => "https://accounts.google.com",
      "picture" => "https://lh3.googleusercontent.com/a/photo",
      "sub" => "104829376510394827561"
    }
  end
end
