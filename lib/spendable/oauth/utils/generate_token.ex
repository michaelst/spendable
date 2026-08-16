defmodule Spendable.OAuth.Utils.GenerateToken do
  @moduledoc false

  @doc """
  Mints a token as a selector and a verifier. Only the selector and a hash of the verifier are
  stored, so the token itself is legible exactly once - to the client it was issued to.
  """
  def generate_token(type) do
    selector = :crypto.strong_rand_bytes(16)
    verifier = :crypto.strong_rand_bytes(16)

    %{
      token: prefix(type) <> Base.url_encode64(selector <> verifier, padding: false),
      selector: selector,
      verifier: verifier
    }
  end

  defp prefix(:access), do: "sp.at."
  defp prefix(:refresh), do: "sp.rt."
  defp prefix(:authorization_code), do: "sp.ac."
  defp prefix(:client_secret), do: "sp.cs."
end
