defmodule Spendable.Banks.Actions.GetBankTransaction do
  @moduledoc false

  alias Spendable.Banks.Schemas.BankTransaction
  alias Spendable.Repo
  alias Spendable.Scope

  def get_bank_transaction(%Scope{user: %{id: user_id}}, by) do
    case Repo.get_by(BankTransaction, Keyword.put(by, :user_id, user_id)) do
      %BankTransaction{} = bank_transaction -> {:ok, bank_transaction}
      nil -> {:error, :bank_transaction_not_found}
    end
  end
end
