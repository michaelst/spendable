defmodule Spendable.Banks.Actions.GetBankAccount do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Repo
  alias Spendable.Scope

  def get_bank_account(%Scope{user: %{id: user_id}}, id) do
    query =
      from(account in BankAccount,
        where: account.user_id == ^user_id,
        where: account.id == ^id
      )

    case Repo.one(query) do
      %BankAccount{} = account -> {:ok, account}
      nil -> {:error, :bank_account_not_found}
    end
  end
end
