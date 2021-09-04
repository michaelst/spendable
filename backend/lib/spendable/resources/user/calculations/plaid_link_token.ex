defmodule Spendable.User.Calculations.PlaidLinkToken do
  use Ash.Calculation, type: :string

  @impl Ash.Calculation
  def calculate([user], _opts, _resolution) do
    with {:ok, %{body: %{"link_token" => token}}} <- Plaid.create_link_token(user.id) do
      {:ok, [token]}
    end
  end
end
