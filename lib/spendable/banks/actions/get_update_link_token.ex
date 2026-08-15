defmodule Spendable.Banks.Actions.GetUpdateLinkToken do
  @moduledoc false

  alias Spendable.Banks.Clients.Plaid
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope

  @doc "A token for reopening an existing connection, to fix an expired login or verify deposits."
  def get_update_link_token(
        %Scope{user: %{id: user_id}},
        %BankMember{user_id: user_id} = bank_member
      ) do
    {:ok, %{body: %{"link_token" => token}}} =
      Plaid.create_link_token(user_id, bank_member.plaid_token)

    {:ok, token}
  end

  def get_update_link_token(_scope, _bank_member), do: {:error, :not_authorized}
end
