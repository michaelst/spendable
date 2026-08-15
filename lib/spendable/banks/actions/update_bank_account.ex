defmodule Spendable.Banks.Actions.UpdateBankAccount do
  @moduledoc false

  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Repo
  alias Spendable.Scope

  def update_bank_account(
        %Scope{user: %{id: user_id}},
        %BankAccount{user_id: user_id} = bank_account,
        attrs
      ) do
    bank_account
    |> BankAccount.changeset(attrs)
    |> Repo.update()
  end

  def update_bank_account(_scope, _bank_account, _attrs), do: {:error, :not_authorized}
end
