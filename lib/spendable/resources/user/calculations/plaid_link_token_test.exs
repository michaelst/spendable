defmodule Spendable.User.Calculations.PlaidLinkTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.Factory
  alias Spendable.User.Calculations.PlaidLinkToken

  test "calculate plaid link token" do
    user = Factory.user()

    token = "link-sandbox-961de9b2-d8f3-43ac-9e9d-c108a555a6ae"

    TeslaMock
    |> expect(:call, fn %{method: :post, url: "https://sandbox.plaid.com/link/token/create"}, _opts ->
      TeslaHelper.response(body: %{"link_token" => token})
    end)

    {:ok, [calculated_token]} = PlaidLinkToken.calculate([user], [], %{})

    assert token == calculated_token
  end

  test "can't get token if at bank limit" do
    user = Factory.user(bank_limit: 0)

    {:error, [:no_connections_available]} = PlaidLinkToken.calculate([user], [], %{})
  end
end
