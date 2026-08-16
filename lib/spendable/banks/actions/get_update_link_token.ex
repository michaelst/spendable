defmodule Spendable.Banks.Actions.GetUpdateLinkToken do
  @moduledoc false

  alias Spendable.Banks.Clients.Plaid
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Scope

  @doc """
  A token for reopening an existing connection, to fix an expired login or verify deposits.

  Plaid only. Passing a connection without a token would fall through to Plaid's new-item clause
  and mint a link token that opens the wrong flow, which is worse than refusing.
  """
  def get_update_link_token(
        %Scope{user: %{id: user_id}},
        %BankMember{user_id: user_id, provider: "Plaid"} = bank_member
      ) do
    {:ok, %{body: %{"link_token" => token}}} =
      Plaid.create_link_token(user_id, bank_member.plaid_token)

    {:ok, token}
  end

  def get_update_link_token(%Scope{user: %{id: user_id}}, %BankMember{user_id: user_id}) do
    {:error, :not_supported}
  end

  def get_update_link_token(_scope, _bank_member), do: {:error, :not_authorized}
end
