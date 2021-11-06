defmodule Spendable.BankMember.Calculations.PlaidLinkToken do
  use Ash.Calculation, type: :string

  @impl Ash.Calculation
  def calculate([bank_member], _opts, _resolution) do
    with {:ok, %{body: %{"link_token" => token}}} <-
           Plaid.create_link_token(bank_member.user_id, bank_member.plaid_token) do
      {:ok, [token]}
    end
  end
end
