defmodule Spendable.BankMember.Calculations.PlaidLinkTokenTest do
  use Spendable.DataCase, async: true

  alias Spendable.User.Calculations.PlaidLinkToken

  test "calculate plaid link token" do
    user = insert(:user)
    %{plaid_token: access_token} = member = insert(:bank_member, user_id: user.id)

    token = "link-sandbox-961de9b2-d8f3-43ac-9e9d-c108a555a6ae"

    Tesla.Mock.mock(fn
      %{method: :post, url: "https://sandbox.plaid.com/link/token/create", body: body} ->
        assert {:ok,
                %{
                  "access_token" => access_token,
                  "client_id" => "test",
                  "client_name" => "Genesis Block",
                  "country_codes" => ["US"],
                  "language" => "en",
                  "secret" => "test",
                  "user" => %{"client_user_id" => "#{user.id}"},
                  "webhook" => "https://spendable.money/plaid/webhook"
                }} == Jason.decode(body)

        %Tesla.Env{status: 200, body: %{"link_token" => token}}
    end)

    {:ok, [calculated_token]} = PlaidLinkToken.calculate([user], [], %{})

    assert token == calculated_token
  end
end
