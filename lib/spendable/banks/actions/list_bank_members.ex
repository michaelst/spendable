defmodule Spendable.Banks.Actions.ListBankMembers do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.Repo
  alias Spendable.Scope

  def list_bank_members(%Scope{user: %{id: user_id}}, opts \\ []) do
    from(member in BankMember,
      where: member.user_id == ^user_id,
      order_by: member.name,
      preload: [bank_accounts: ^from(account in Spendable.Banks.Schemas.BankAccount, order_by: account.name)]
    )
    |> maybe_search(opts[:search])
    |> Repo.all()
  end

  defp maybe_search(query, search) when is_binary(search) and byte_size(search) > 0 do
    where(query, [member], ilike(member.name, ^"%#{search}%"))
  end

  defp maybe_search(query, _search), do: query
end
