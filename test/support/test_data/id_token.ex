defmodule Spendable.TestData.IdToken do
  @moduledoc """
  A throwaway RSA keypair standing in for an OpenID provider's, so tests can sign an ID token the
  real verification path accepts. Generated once at compile time - generating per test costs more
  than the tests do.
  """

  @kid "test-key"

  @keypair JOSE.JWK.generate_key({:rsa, 2048})
  @private_key @keypair |> JOSE.JWK.to_map() |> elem(1)
  @public_key @keypair |> JOSE.JWK.to_public_map() |> elem(1)

  @doc "The JWKS document a provider serves."
  def certs(), do: %{"keys" => [Map.put(@public_key, "kid", @kid)]}

  @doc "An ID token signed by the key `certs/0` publishes."
  def sign(claims), do: sign(claims, @private_key)

  @doc "An ID token signed by a key no provider publishes."
  def sign_with_unknown_key(claims) do
    sign(claims, {:rsa, 2048} |> JOSE.JWK.generate_key() |> JOSE.JWK.to_map() |> elem(1))
  end

  @doc "An expiry an hour out, which is what a freshly minted token carries."
  def expires_at(), do: DateTime.utc_now() |> DateTime.add(1, :hour) |> DateTime.to_unix()

  defp sign(claims, key) do
    Joken.generate_and_sign!(%{}, claims, Joken.Signer.create("RS256", key, %{"kid" => @kid}))
  end
end
