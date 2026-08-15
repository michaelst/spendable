defmodule Spendable.Transactions.Actions.CreateTransaction do
  @moduledoc false

  alias Spendable.Repo
  alias Spendable.Scope
  alias Spendable.Transactions.Schemas.Transaction

  def create_transaction(%Scope{user: %{id: user_id}}, attrs) do
    %Transaction{user_id: user_id}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end
end
