defmodule Spendable.Banks.Actions.UpsertBankAccount do
  @moduledoc false

  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope

  @doc """
  Records one of a connection's accounts as the source last reported it.

  Matched on `external_id`, which is what makes a second sync update the account already held
  rather than adding a copy of it.
  """
  def upsert_bank_account(
        %Scope{user: %{id: user_id}},
        %BankMember{user_id: user_id} = bank_member,
        %{external_id: external_id} = attrs
      ) do
    bank_account =
      Repo.get_by(BankAccount, user_id: user_id, external_id: external_id) ||
        %BankAccount{user_id: user_id, bank_member_id: bank_member.id}

    bank_account
    |> BankAccount.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def upsert_bank_account(_scope, _bank_member, _attrs), do: {:error, :not_authorized}
end
