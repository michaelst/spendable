defmodule Spendable.Accounts.Actions.RegisterApnsToken do
  @moduledoc false

  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Registers the device a token was issued to for push. It rides on the token row rather than a
  table of its own, so revoking the token stops the pushes with it.
  """
  def register_apns_token(
        %Scope{user: %{id: user_id}},
        %ApiToken{user_id: user_id} = api_token,
        apns_token
      ) do
    api_token
    |> ApiToken.changeset(%{apns_token: apns_token})
    |> Repo.update()
  end

  def register_apns_token(%Scope{}, %ApiToken{}, _apns_token), do: {:error, :not_authorized}
end
