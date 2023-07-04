defmodule Spendable.BankMember.Calculations.PlaidLinkTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.BankMember.Calculations.PlaidLinkToken
  alias Spendable.Factory

  test "calculate plaid link token" do
    user = Factory.user()

    %{plaid_token: access_token} =
      bank_member = Factory.bank_member(user)

    token = "link-sandbox-961de9b2-d8f3-43ac-9e9d-c108a555a6ae"

    TeslaMock
    |> expect(:call, fn
      %{method: :post, url: "https://sandbox.plaid.com/link/token/create", body: body}, _opts ->
        assert {:ok,
                %{
                  "access_token" => access_token,
                  "client_id" => "test",
                  "client_name" => "Spendable",
                  "country_codes" => ["US"],
                  "language" => "en",
                  "secret" => "test",
                  "user" => %{"client_user_id" => "#{user.id}"},
                  "webhook" => "https://spendable.money/plaid/webhook"
                }} == Jason.decode(body)

        TeslaHelper.response(status: 200, body: %{"link_token" => token})
    end)

    {:ok, [calculated_token]} = PlaidLinkToken.calculate([bank_member], [], %{})

    assert token == calculated_token
  end
end
