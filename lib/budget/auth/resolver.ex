defmodule Budget.Auth.Resolver do
  alias Budget.Auth.Utils
  alias Budget.Guardian

  def login(params, _info) do
    with {:ok, user} <- Utils.authenticate(params),
         {:ok, token, _} <- Guardian.encode_and_sign(user) do
      {:ok, Map.put(user, :token, token)}
    end
  end
end
