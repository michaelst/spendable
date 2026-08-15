defmodule Spendable.Banks.Actions.GetBankMemberByExternalId do
  @moduledoc false

  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo

  @doc """
  Looks a member up by the id Plaid knows it as.

  Takes no scope: Plaid's webhook names the item, not a user, and the owner is what we are
  looking up.
  """
  def get_bank_member_by_external_id(external_id) when is_binary(external_id) do
    case Repo.get_by(BankMember, external_id: external_id) do
      %BankMember{} = bank_member -> {:ok, bank_member}
      nil -> {:error, :bank_member_not_found}
    end
  end
end
