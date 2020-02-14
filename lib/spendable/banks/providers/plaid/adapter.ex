defmodule Spendable.Banks.Providers.Plaid.Adapter do
  alias Spendable.Banks.Category
  alias Spendable.Repo

  def format(%{"item" => details}, user_id, :member) do
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
      status: details["error"]["error_code"] || "CONNECTED",
      user_id: user_id
    }
  end

  def format(details, member_id, user_id, :account) do
    %{
      available_balance: details["balances"]["available"],
      balance: details["balances"]["current"],
      external_id: details["account_id"],
      bank_member_id: member_id,
      name: details["official_name"] || details["name"],
      number: details["mask"],
      sub_type: details["subtype"],
      type: details["type"],
      user_id: user_id
    }
  end

  def format(details, account_id, user_id, :bank_transaction) do
    %{
      bank_account_id: account_id,
      user_id: user_id,
      category_id: Repo.get_by!(Category, external_id: details["category_id"]).id,
      amount: details["amount"] * -1,
      date: details["date"],
      external_id: details["transaction_id"],
      name: details["name"],
      pending: details["pending"]
    }
  end

  def format(bank_transaction, :transaction) do
    %{
      bank_account_id: bank_transaction.bank_account_id,
      bank_transaction_id: bank_transaction.id,
      user_id: bank_transaction.user_id,
      category_id: bank_transaction.category_id,
      amount: bank_transaction.amount,
      date: bank_transaction.date,
      name: bank_transaction.name
    }
  end
end
