defmodule Spendable.TestData.Apple do
  @moduledoc false

  alias Spendable.TestData.IdToken

  @audience "fiftysevenmedia.Spendable"

  defdelegate certs(), to: IdToken

  @doc "An ID token Apple would have signed. Pass claims to override the defaults."
  def id_token(claims \\ %{}), do: IdToken.sign(Map.merge(default_claims(), claims))

  defp default_claims() do
    %{
      "aud" => @audience,
      "email" => "michael@dishbooks.com",
      "email_verified" => "true",
      "exp" => IdToken.expires_at(),
      "iss" => "https://appleid.apple.com",
      "sub" => "001234.fedcba9876543210fedcba9876543210.1234"
    }
  end
end
