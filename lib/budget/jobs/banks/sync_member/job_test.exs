defmodule Budget.Jobs.Banks.SyncMemberTest do
  use Budget.DataCase, async: true
  import Tesla.Mock

  alias Budget.{
    Jobs.Banks.SyncMemberTest.TestData,
    Banks.Member,
    Banks.Providers.Plaid.Adapter
  }

  alias Budget.Banks.Category.TestData, as: CategoryTestData

  setup do
    mock(fn
      %{method: :post, url: "https://sandbox.plaid.com/categories/get"} ->
        json(CategoryTestData.categories())

      %{method: :post, url: "https://sandbox.plaid.com/item/get"} ->
        json(TestData.item())

      %{
        method: :post,
        url: "https://sandbox.plaid.com/institutions/get_by_id",
        body:
          "{\"institution_id\":\"ins_109511\",\"options\":{\"include_optional_metadata\":true},\"public_key\":\"test\"}"
      } ->
        json(TestData.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"} ->
        json(TestData.accounts())

      %{
        method: :post,
        url: "https://sandbox.plaid.com/transactions/get",
        body:
          "{\"access_token\":\"access-sandbox-97a66034-85df-4510-8eb5-020cc7997134\",\"client_id\":\"test\",\"end_date\":\"2019-10-11\",\"options\":{\"account_ids\":[\"zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP\"],\"count\":500,\"offset\":0},\"secret\":\"test\",\"start_date\":\"2018-01-01\"}"
      } ->
        json(TestData.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))

      body ->
        IO.inspect(body)
    end)

    :ok
  end

  test "sync member" do
    {user, _} = Budget.TestUtils.create_user()
    token = "access-sandbox-97a66034-85df-4510-8eb5-020cc7997134"
    {:ok, %{body: details}} = Plaid.member(token)

    Budget.Banks.Category.Utils.import_categories()

    member =
      %Member{plaid_token: token}
      |> Member.changeset(Adapter.format(details, user.id, :member))
      |> Repo.insert!()

    Budget.Jobs.Banks.SyncMember.perform(member.id)
  end
end
