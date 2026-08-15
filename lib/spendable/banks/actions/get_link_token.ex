defmodule Spendable.Banks.Actions.GetLinkToken do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Banks.Clients.Plaid
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  A token for Plaid Link to open a new connection with.

  Refused once the user is at their bank limit, so the check happens before Plaid is called
  rather than after the user has picked a bank.
  """
  def get_link_token(%Scope{user: user}) do
    connected = Repo.aggregate(from(m in BankMember, where: m.user_id == ^user.id), :count, :id)

    if connected < user.bank_limit do
      {:ok, %{body: %{"link_token" => token}}} = Plaid.create_link_token(user.id)
      {:ok, token}
    else
      {:error, :bank_limit_reached}
    end
  end
end
