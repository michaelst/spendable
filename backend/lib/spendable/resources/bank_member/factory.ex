defmodule Spendable.BankMember.Factory do
  def default() do
    %{
      external_id: Ecto.UUID.generate(),
      institution_id: "ins_1",
      name: "Plaid",
      plaid_token: "access-sandbox-898addd0-d983-45f8-a034-3b29d62794a7",
      provider: "Plaid",
      status: "CONNECTED"
    }
  end
end
