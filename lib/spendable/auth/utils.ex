defmodule Spendable.Auth.Utils do
  alias Spendable.Repo
  alias Spendable.User

  def authenticate(%{token: token}) do
    with %{fields: %{"kid" => kid}} <- JOSE.JWT.peek_protected(token),
         {true, json_payload, _} <- JOSE.JWK.verify(token, apple_jwk(kid)),
         {:ok, %{"sub" => apple_identifier}} <- Jason.decode(json_payload) do
      case Spendable.Repo.get_by(Spendable.User, apple_identifier: apple_identifier) do
        nil ->
          struct(User)
          |> User.changeset(%{apple_identifier: apple_identifier})
          |> Repo.insert()

        user ->
          {:ok, user}
      end
    else
      _ -> {:error, "Login failed"}
    end
  end

  def authenticate(params) do
    with user when not is_nil(user) <- Spendable.Repo.get_by(Spendable.User, email: String.downcase(params.email)),
         true <- Bcrypt.verify_pass(params.password, user.password) do
      {:ok, user}
    else
      _ -> {:error, "Incorrect login credentials"}
    end
  end

  def apple_jwk(kid) do
    [jwks: jwks] = :ets.lookup(:apple, :jwks)
    jwks[kid]
  rescue
    _ ->
      {:ok, %{body: %{"keys" => keys}}} = Apple.public_keys()

      jwks =
        JOSE.JWK.from(keys)
        |> Enum.map(fn %{fields: %{"kid" => kid}} = jwk -> {kid, jwk} end)
        |> Map.new()

      :ets.new(:apple, [:named_table])
      :ets.insert(:apple, {:jwks, jwks})
      jwks[kid]
  end
end
