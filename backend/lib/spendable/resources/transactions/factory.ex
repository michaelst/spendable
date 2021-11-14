defmodule Spendable.Transaction.Factory do
  def default() do
    %{
      amount: 10.25,
      date: Date.utc_today(),
      name: "test",
      note: "some notes",
      reviewed: false
    }
  end
end
