defmodule Spendable.Banks.Actions.GetLinkToken do
  @moduledoc false

  import Spendable.Banks.Utils.CountPlaidMembers

  alias Spendable.Banks.Clients.Plaid
  alias Spendable.Scope

  @doc """
  A token for Plaid Link to open a new connection with.

  Refused once the user is at their bank limit, so the check happens before Plaid is called
  rather than after the user has picked a bank.
  """
  def get_link_token(%Scope{user: user}) do
    if count_plaid_members(user) < user.bank_limit do
      {:ok, %{body: %{"link_token" => token}}} = Plaid.create_link_token(user.id)
      {:ok, token}
    else
      {:error, :bank_limit_reached}
    end
  end
end
