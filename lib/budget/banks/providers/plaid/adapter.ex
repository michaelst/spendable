defmodule Budget.Banks.Providers.Plaid.Adapter do
  def format(%{"item" => details}, user_id, :member) do
    {:ok,
     %{
       body: %{
         "institution" => %{
           "name" => name,
           "logo" => logo
         }
       }
     }} = Plaid.institution(institution_id)

    %{
      external_id: details["item_id"],
      institution_id: details["institution_id"],
      logo: logo,
      name: name,
      provider: "Plaid",
      status: details["status"],
      user_id: user_id
    }
  end

  def format(details, member_id, user_id, :account) do
    %{
      user_id: user_id,
      member_id: member_id,
      external_id: details["account_id"],
      available_balance: details["balances"]["available"],
      balance: details["balances"]["current"],
      name: details["official_name"],
      number: details["mask"],
      sub_type: details["subtype"],
      type: details["type"]
    }
  end
end
