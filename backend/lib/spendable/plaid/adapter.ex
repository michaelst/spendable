defmodule Spendable.Plaid.Adapter do
  def bank_member(%{"item" => details}) do
    {:ok,
     %{
       body: %{
         "institution" => %{
           "name" => name,
           "logo" => logo
         }
       }
     }} = Plaid.institution(details["institution_id"])

    %{
      external_id: details["item_id"],
      institution_id: details["institution_id"],
      logo: logo,
      name: name,
      provider: "Plaid",
      status: details["error"]["error_code"] || "CONNECTED"
    }
  end

  def bank_account(details) do
    available_balance = Decimal.new("#{details["balances"]["available"] || 0}")
    current_balance = Decimal.new("#{details["balances"]["current"]}")

    balance =
      cond do
        details["type"] == "credit" ->
          Decimal.mult(current_balance, "-1")

        Decimal.eq?(available_balance, "0") ->
          current_balance

        true ->
          available_balance
      end

    %{
      available_balance: balance,
      balance: balance,
      external_id: details["account_id"],
      name: details["official_name"] || details["name"],
      number: details["mask"],
      sub_type: details["subtype"],
      type: details["type"]
    }
  end

  def bank_transaction(details) do
    %{
      amount: details["amount"] |> to_string() |> Decimal.new() |> Decimal.negate() |> Decimal.round(2),
      date: details["date"],
      external_id: details["transaction_id"],
      name: details["name"],
      pending: details["pending"]
    }
  end

  def transaction(bank_transaction) do
    %{
      amount: bank_transaction.amount,
      date: bank_transaction.date,
      name: bank_transaction.name,
      reviewed: false
    }
  end
end
