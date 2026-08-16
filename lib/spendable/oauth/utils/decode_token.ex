defmodule Spendable.OAuth.Utils.DecodeToken do
  @moduledoc false

  @doc """
  Splits a token back into the selector that finds its row and the verifier that proves it, the
  pair `Spendable.OAuth.Utils.GenerateToken` minted it from.
  """
  def decode_token(token, type) do
    prefix = prefix(type)

    with true <- String.starts_with?(token, prefix),
         encoded = String.replace_prefix(token, prefix, ""),
         {:ok, <<selector::binary-size(16), verifier::binary-size(16)>>} <-
           Base.url_decode64(encoded, padding: false) do
      {:ok, selector, verifier}
    else
      _error -> :error
    end
  end

  defp prefix(:access), do: "sp.at."
  defp prefix(:refresh), do: "sp.rt."
  defp prefix(:authorization_code), do: "sp.ac."
  defp prefix(:client_secret), do: "sp.cs."
end
