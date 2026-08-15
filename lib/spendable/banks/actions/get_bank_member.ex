defmodule Spendable.Banks.Actions.GetBankMember do
  @moduledoc false

  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope

  def get_bank_member(%Scope{user: %{id: user_id}}, by) do
    case Repo.get_by(BankMember, Keyword.put(by, :user_id, user_id)) do
      %BankMember{} = bank_member -> {:ok, bank_member}
      nil -> {:error, :bank_member_not_found}
    end
  end
end
