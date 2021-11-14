defmodule Spendable.BankAccount.Factory do
  def default() do
    %{
      external_id: Ecto.UUID.generate(),
      name: "Checking",
      balance: Decimal.new("100.00"),
      type: "depository",
      sub_type: "checking",
      sync: true
    }
  end
end
