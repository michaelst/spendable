defmodule Spendable.Banks.Actions.CreateBankMemberFromPublicToken do
  @moduledoc false

  import Ecto.Query
  import Spendable.Banks.Utils.FormatBankMember

  alias Spendable.Banks
  alias Spendable.Banks.Clients.Plaid
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Exchanges Plaid's short-lived public token for the access token we keep, then queues the first
  sync so the accounts and their history arrive without the user waiting on them.
  """
  def create_bank_member_from_public_token(%Scope{user: user} = scope, public_token) do
    connected = Repo.aggregate(from(m in BankMember, where: m.user_id == ^user.id), :count, :id)

    if connected < user.bank_limit do
      exchange_and_insert(scope, public_token)
    else
      {:error, :bank_limit_reached}
    end
  end

  defp exchange_and_insert(%Scope{user: user}, public_token) do
    {:ok, %{body: %{"access_token" => plaid_token}}} = Plaid.exchange_public_token(public_token)
    {:ok, %{body: item}} = Plaid.item(plaid_token)

    # No accounts until the sync lands, but an empty list is readable where an unloaded one is not.
    %BankMember{user_id: user.id, plaid_token: plaid_token, bank_accounts: []}
    |> BankMember.changeset(format_bank_member(item))
    |> Repo.insert()
    |> case do
      {:ok, bank_member} ->
        {:ok, _job} = Banks.queue_sync(bank_member)
        {:ok, bank_member}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
