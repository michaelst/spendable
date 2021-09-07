defmodule Spendable.BankMember.GraphQLTests do
  use Spendable.DataCase, async: true

  import Mock
  import Spendable.Factory
  import Tesla.Mock

  alias Google.PubSub
  alias Spendable.TestUtils

  describe "member" do
    test "get member" do
      user = insert(:user)
      member = insert(:bank_member, user_id: user.id)

      doc = """
      query {
        bankMember(id: "#{member.id}") {
          id
        }
      }
      """

      assert {:ok,
              %{
                data: %{
                  "bankMember" => %{
                    "id" => "#{member.id}"
                  }
                }
              }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})
    end

    test "plaid link token" do
      user = insert(:user)
      %{plaid_token: access_token} = member = insert(:bank_member, user_id: user.id)
      token = "link-sandbox-961de9b2-d8f3-43ac-9e9d-c108a555a6ae"

      Tesla.Mock.mock(fn
        %{method: :post, url: "https://sandbox.plaid.com/link/token/create", body: body} ->
          assert {:ok, %{"access_token" => ^access_token}} = Jason.decode(body)
          %Tesla.Env{status: 200, body: %{"link_token" => token}}
      end)

      doc = """
      query {
        bankMember(id: "#{member.id}") {
          plaidLinkToken
        }
      }
      """

      assert {:ok,
              %{
                data: %{
                  "bankMember" => %{
                    "plaidLinkToken" => token
                  }
                }
              }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: user})
    end
  end

  test "list members" do
    user = insert(:user)
    member = insert(:bank_member, user_id: user.id)

    checking_account =
      insert(:bank_account,
        user_id: user.id,
        bank_member_id: member.id,
        name: "Checking",
        available_balance: 100,
        balance: 120
      )

    savings_account =
      insert(:bank_account,
        user_id: user.id,
        bank_member_id: member.id,
        name: "Savings",
        available_balance: nil,
        balance: 500
      )

    credit_account =
      insert(:bank_account,
        user_id: user.id,
        bank_member_id: member.id,
        name: "Credit Card",
        balance: 1025,
        type: "credit"
      )

    query = """
    query {
      bankMembers {
        id
        name
        status
        bankAccounts {
          id
          name
          sync
          balance
        }
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "bankMembers" => [
                  %{
                    "bankAccounts" => [
                      %{"balance" => "100.00", "id" => "#{checking_account.id}", "name" => "Checking", "sync" => true},
                      %{
                        "balance" => "-1025.00",
                        "id" => "#{credit_account.id}",
                        "name" => "Credit Card",
                        "sync" => true
                      },
                      %{"balance" => "500.00", "id" => "#{savings_account.id}", "name" => "Savings", "sync" => true}
                    ],
                    "id" => "#{member.id}",
                    "name" => "Plaid",
                    "status" => "Connected"
                  }
                ]
              }
            }} == Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})
  end

  describe "create" do
    setup do
      mock(fn
        %{method: :post, url: "https://sandbox.plaid.com/item/public_token/exchange"} ->
          json(%{
            access_token: "access-sandbox-de3ce8ef-33f8-452c-a685-8671031fc0f6",
            item_id: "M5eVJqLnv3tbzdngLDp9FL5OlDNxlNhlE55op",
            request_id: "Aim3b"
          })

        %{method: :post, url: "https://sandbox.plaid.com/item/get"} ->
          json(%{
            item: %{
              error: nil,
              institution_id: "ins_109508",
              item_id: "M5eVJqLnv3tbzdngLDp9FL5OlDNxlNhlE55op",
              webhook: "https://plaid.com/example/hook"
            },
            request_id: "m8MDnv9okwxFNBV"
          })

        %{method: :post, url: "https://sandbox.plaid.com/accounts/get"} ->
          json(%{
            "accounts" => [
              %{
                "account_id" => "5voA7reA6GsVgexwgKAphW6EzRlQPWuxBEboR",
                "balances" => %{
                  "available" => 100,
                  "current" => 110,
                  "iso_currency_code" => "USD",
                  "limit" => nil,
                  "unofficial_currency_code" => nil
                },
                "mask" => "0000",
                "name" => "Plaid Checking",
                "official_name" => "Plaid Gold Standard 0% Interest Checking",
                "subtype" => "checking",
                "type" => "depository"
              },
              %{
                "account_id" => "JMEjk8lj9Ru6BnXdBQlqSqlezdbL7qHb7G1Em",
                "balances" => %{
                  "available" => 200,
                  "current" => 210,
                  "iso_currency_code" => "USD",
                  "limit" => nil,
                  "unofficial_currency_code" => nil
                },
                "mask" => "1111",
                "name" => "Plaid Saving",
                "official_name" => "Plaid Silver Standard 0.1% Interest Saving",
                "subtype" => "savings",
                "type" => "depository"
              }
            ],
            "item" => %{
              "available_products" => [
                "assets",
                "auth",
                "balance",
                "credit_details",
                "identity",
                "income",
                "investments",
                "liabilities"
              ],
              "billed_products" => ["transactions"],
              "consent_expiration_time" => nil,
              "error" => nil,
              "institution_id" => "ins_3",
              "item_id" => "NoRZqGzZgbFB6XAe6mzZcyeBKko3EpTW6j1pq",
              "webhook" => ""
            },
            "request_id" => "qohhGRqmjw7RiUX"
          })

        %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"} ->
          json(%{
            institution: %{
              name: "Plaid Bank",
              primary_color: "#1f1f1f",
              url: "https://plaid.com",
              logo: "https://plaid.com"
            },
            request_id: "m8MDnv9okwxFNBV"
          })
      end)

      :ok
    end

    setup_with_mocks([
      {
        PubSub,
        [],
        publish: fn data, _topic ->
          send(self(), data)
          {:ok, %{status: 200}}
        end
      }
    ]) do
      :ok
    end

    test "create member from plaid public token" do
      user = insert(:user)

      query = """
        mutation {
          createBankMember(
            publicToken: "test"
          ) {
            id, externalId, name, logo, status
          }
        }
      """

      assert {:ok,
              %{
                data: %{
                  "createBankMember" => %{
                    "externalId" => "M5eVJqLnv3tbzdngLDp9FL5OlDNxlNhlE55op",
                    "name" => "Plaid Bank",
                    "logo" => "https://plaid.com",
                    "status" => "CONNECTED",
                    "id" => member_id
                  }
                }
              }} = Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

      TestUtils.assert_published(%SyncMemberRequest{member_id: String.to_integer(member_id)})
    end
  end
end
