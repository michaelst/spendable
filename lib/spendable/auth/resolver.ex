defmodule Spendable.Auth.Resolver do
  alias Spendable.Auth.Utils
  alias Spendable.Guardian

  def login(params, _info) do
    with {:ok, user} <- Utils.authenticate(params),
         {:ok, token, _} <- Guardian.encode_and_sign(user) do
      {:ok, Map.put(user, :token, token)}
    end
  end
end
