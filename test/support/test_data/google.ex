defmodule Spendable.TestData.Google do
  @moduledoc false

  alias Spendable.TestData.IdToken

  @audience "spendable-ios.apps.googleusercontent.com"

  defdelegate certs(), to: IdToken

  @doc "An ID token Google would have signed. Pass claims to override the defaults."
  def id_token(claims \\ %{}), do: IdToken.sign(Map.merge(default_claims(), claims))

  @doc "An ID token signed by a key Google does not publish."
  def id_token_from_unknown_key(), do: IdToken.sign_with_unknown_key(default_claims())

  defp default_claims() do
    %{
      "aud" => @audience,
      "email" => "michael@dishbooks.com",
      "exp" => IdToken.expires_at(),
      "iss" => "https://accounts.google.com",
      "picture" => "https://lh3.googleusercontent.com/a/photo",
      "sub" => "104829376510394827561"
    }
  end
end
