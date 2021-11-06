defmodule Spendable.BankMember.GraphQLTests do
  use Spendable.DataCase, async: false

  import Mock

  import Tesla.Mock

  alias Google.PubSub
  alias Spendable.TestUtils

  describe "member" do
    test "get member" do
      user = insert(:user)
      other_user = insert(:user)
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

      assert {:ok,
              %{
                data: nil,
                errors: [
                  %{
                    code: "not_found",
                    locations: [%{column: 3, line: 2}],
                    message: "could not be found",
                    path: ["bankMember"],
                    fields: [:id],
                    short_message: "could not be found",
                    vars: []
                  }
                ]
              }} == Absinthe.run(doc, Spendable.Web.Schema, context: %{actor: other_user})
    end
  end

  test "list members" do
    user = insert(:user)
    member = insert(:bank_member, user_id: user.id)
    # this one shouldn't be returned
    other_user = insert(:user)
    insert(:bank_member, user_id: other_user.id)

    query = """
    query {
      bankMembers {
        id
      }
    }
    """

    assert {:ok,
            %{
              data: %{
                "bankMembers" => [
                  %{
                    "id" => "#{member.id}"
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
          createBankMember(input: { publicToken: "test" }) {
            result {
              id
              externalId
              name
              logo
              status
            }
          }
        }
      """

      assert {:ok,
              %{
                data: %{
                  "createBankMember" => %{
                    "result" => %{
                      "externalId" => "M5eVJqLnv3tbzdngLDp9FL5OlDNxlNhlE55op",
                      "name" => "Plaid Bank",
                      "logo" => "https://plaid.com",
                      "status" => "CONNECTED",
                      "id" => member_id
                    }
                  }
                }
              }} = Absinthe.run(query, Spendable.Web.Schema, context: %{actor: user})

      TestUtils.assert_published(%SyncMemberRequest{member_id: String.to_integer(member_id)})
    end
  end
end
