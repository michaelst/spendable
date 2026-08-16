defmodule Spendable.OAuth.Utils.VerifyPkceChallenge do
  @moduledoc false

  @doc """
  Whether the verifier the client kept hashes to the challenge it published when it asked, which
  is what stops a stolen code being redeemed by anyone else.
  """
  def verify_pkce_challenge(code_verifier, code_challenge) do
    computed = Base.url_encode64(:crypto.hash(:sha256, code_verifier), padding: false)

    Plug.Crypto.secure_compare(computed, code_challenge)
  end
end
