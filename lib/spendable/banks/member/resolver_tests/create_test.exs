defmodule Spendable.Member.Resolver.CreateTest do
  use SpendableWeb.ConnCase, async: true
  import Tesla.Mock

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

  test "create member from plaid public token", %{conn: conn} do
    {_user, token} = Spendable.TestUtils.create_user()

    query = """
      mutation {
        createBankMember(
          publicToken: "test"
        ) {
          id, externalId, name, logo, status
        }
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/graphql", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "createBankMember" => %{
                 "externalId" => "M5eVJqLnv3tbzdngLDp9FL5OlDNxlNhlE55op",
                 "name" => "Plaid Bank",
                 "logo" => "https://plaid.com",
                 "status" => nil,
                 "id" => member_id
               }
             }
           } = response

    Spendable.TestUtils.assert_job(Spendable.Jobs.Banks.SyncMember, [String.to_integer(member_id)])
  end
end
