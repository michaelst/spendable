defmodule Budget.Member.Resolver.CreateTest do
  use BudgetWeb.ConnCase, async: true
  import Tesla.Mock

  alias Budget.User
  alias Budget.Repo
  alias Budget.Guardian

  setup do
    mock(fn
      %{method: :post, url: "https://sandbox.plaid.com/item/public_token/exchange"} ->
        json(%{
          access_token: "access-sandbox-de3ce8ef-33f8-452c-a685-8671031fc0f6",
          item_id: "M5eVJqLnv3tbzdngLDp9FL5OlDNxlNhlE55op",
          request_id: "Aim3b"
        })
    end)

    :ok
  end

  test "create member from plaid public token", %{conn: conn} do
    email = "#{Ecto.UUID.generate()}@example.com"
    user = struct(User) |> User.changeset(%{email: email, password: "password"}) |> Repo.insert!()
    {:ok, token, _} = Guardian.encode_and_sign(user)

    query = """
      mutation {
        createBankMember(
          publicToken: "test"
        ) {
          id, externalId
        }
      }
    """

    response =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> post("/", %{query: query})
      |> json_response(200)

    assert %{
             "data" => %{
               "createBankMember" => %{
                 "externalId" => "M5eVJqLnv3tbzdngLDp9FL5OlDNxlNhlE55op",
                 "id" => _
               }
             }
           } = response
  end
end
