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
      _match -> {:error, "Login failed"}
    end
  end

  def authenticate(params) do
    with user when is_struct(user) <- Spendable.Repo.get_by(Spendable.User, email: String.downcase(params.email)),
         true <- Bcrypt.verify_pass(params.password, user.password) do
      {:ok, user}
    else
      _match -> {:error, "Incorrect login credentials"}
    end
  end

  def apple_jwk(kid) do
    {:ok, %{body: %{"keys" => keys}}} = Apple.public_keys()

    keys
    |> Enum.find(&(&1["kid"] == kid))
    |> JOSE.JWK.from()
  end
end
