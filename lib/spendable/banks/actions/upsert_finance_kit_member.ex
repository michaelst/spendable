defmodule Spendable.Banks.Actions.UpsertFinanceKitMember do
  @moduledoc false

  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope

  @external_id "finance_kit"

  @doc """
  The one connection holding whatever the device reads out of Wallet - Apple Card, Apple Cash and
  Apple Savings alike.

  Idempotent, because the app asks for it every time the user authorizes it, and the answer
  carries the `history_token` saying where the last read left off.
  """
  def upsert_finance_kit_member(%Scope{user: user}) do
    case Repo.get_by(BankMember, user_id: user.id, external_id: @external_id) do
      %BankMember{} = bank_member ->
        {:ok, Repo.preload(bank_member, :bank_accounts)}

      nil ->
        # No accounts until the device sends them, but an empty list is readable where an
        # unloaded one is not.
        %BankMember{user_id: user.id, bank_accounts: []}
        |> BankMember.changeset(%{
          external_id: @external_id,
          name: "Apple",
          provider: "FinanceKit",
          status: "CONNECTED"
        })
        |> Repo.insert()
    end
  end
end
