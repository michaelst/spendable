defmodule Budget.Banks.Providers.Plaid.Adapter do
  def format(%{"access_token" => token, "item_id" => item_id}, user, :member) do
    {:ok,
     %{
       body: %{
         "item" => %{
           "error" => status,
           "institution_id" => institution_id
         }
       }
     }} = Plaid.member(token)

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
      external_id: item_id,
      institution_id: institution_id,
      logo: logo,
      name: name,
      plaid_token: token,
      provider: "Plaid",
      status: status,
      user_id: user.id
    }
  end
end
