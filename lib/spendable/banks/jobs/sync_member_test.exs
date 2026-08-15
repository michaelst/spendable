defmodule Spendable.Banks.Jobs.SyncMemberTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Banks.Jobs.SyncMember
  alias Spendable.Banks.Schemas.BankMember
  alias Spendable.TestData

  setup do
    test_pid = self()

    stub(TeslaMock, :call, fn
      %{method: :post, url: "https://sandbox.plaid.com/item/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.item())

      %{method: :post, url: "https://sandbox.plaid.com/institutions/get_by_id"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.institution())

      %{method: :post, url: "https://sandbox.plaid.com/accounts/get"}, _opts ->
        TeslaHelper.response(body: TestData.Plaid.accounts())

      %{method: :post, url: "https://sandbox.plaid.com/transactions/get", body: body}, _opts ->
        send(test_pid, {:transactions_request, Jason.decode!(body)})

        TeslaHelper.response(body: TestData.Plaid.account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP"))
    end)

    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    {:ok, bank_member} =
      Repo.insert(%BankMember{
        user_id: user.id,
        external_id: "jQ3ZbE3BWqUMeqNBgDK6fjdyErroNwu1EPKnL",
        name: "Plaid",
        provider: "Plaid",
        plaid_token: "access-sandbox-token"
      })

    %{bank_member: bank_member}
  end

  test "pulls the last 30 days when the job carries no start date", %{bank_member: bank_member} do
    assert :ok = perform_job(SyncMember, %{"bank_member_id" => bank_member.id})

    assert_received {:transactions_request, %{"start_date" => start_date}}
    assert start_date == Date.to_iso8601(Date.add(Date.utc_today(), -30))
  end

  test "pulls from the start date the job carries", %{bank_member: bank_member} do
    args = %{"bank_member_id" => bank_member.id, "start_date" => "2024-01-01"}

    assert :ok = perform_job(SyncMember, args)

    assert_received {:transactions_request, %{"start_date" => "2024-01-01"}}
  end
end
