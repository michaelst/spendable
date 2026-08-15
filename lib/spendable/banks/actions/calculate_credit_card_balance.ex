defmodule Spendable.Banks.Actions.CalculateCreditCardBalance do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Banks.Schemas.BankAccount
  alias Spendable.Repo
  alias Spendable.Scope

  @zero Decimal.new("-0.00")

  @doc "What is owed across synced credit cards, as the cards themselves report it."
  def calculate_credit_card_balance(%Scope{user: %{id: user_id}}) do
    from(account in BankAccount,
      where: account.user_id == ^user_id,
      where: account.sub_type == "credit card",
      where: account.sync
    )
    |> Repo.aggregate(:sum, :balance)
    |> Kernel.||(@zero)
  end
end
