defmodule Budget.Auth.Resolver do
  def login(params, _info) do
    with {:ok, user} <- Budget.Auth.Utils.authenticate(params),
         {:ok, token, _} <- Budget.Guardian.encode_and_sign(user) do
      {:ok, Map.put(user, :token, token)}
    end
  end
end
