defmodule Spendable.TestData.FinanceKit do
  @moduledoc false

  alias Spendable.Banks

  @doc """
  One charge on an Apple Card, built the way the device would send it.

  Every record still goes through the context; this only saves repeating the three calls it takes
  to get from a user to a charge.
  """
  def card_with_charge(scope, entry \\ %{}) do
    {:ok, member} = Banks.upsert_finance_kit_member(scope)

    {:ok, bank_account} =
      Banks.upsert_bank_account(scope, member, %{
        balance: Decimal.new("-42.00"),
        external_id: "apple-card",
        name: "Apple Card",
        sub_type: "credit card",
        type: "credit"
      })

    entry = charge(entry)
    {:ok, 1} = Banks.ingest_bank_transactions(scope, bank_account, [entry])
    {:ok, bank_transaction} = Banks.get_bank_transaction(scope, external_id: entry.external_id)

    {bank_account, bank_transaction}
  end

  def charge(attrs \\ %{}) do
    Map.merge(
      %{
        amount: Decimal.new("-20.00"),
        date: ~D[2026-08-01],
        external_id: "txn-1",
        name: "Coffee",
        pending: true,
        replaces: nil
      },
      attrs
    )
  end
end
