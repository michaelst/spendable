defmodule Spendable.Accounts.Jobs.SendNotificationTest do
  use Spendable.DataCase, async: true

  alias Spendable.Accounts
  alias Spendable.Accounts.Jobs.SendNotification
  alias Spendable.Scope

  @device_token String.duplicate("ab", 32)

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, api_token} = Accounts.create_api_token(scope, %{})
    {:ok, _registered} = Accounts.register_apns_token(scope, api_token, @device_token)

    %{user: user}
  end

  test "pushes what the job carries", %{user: user} do
    expect(TeslaMock, :call, fn %{body: body}, _opts ->
      send(self(), {:pushed, body})

      TeslaHelper.response(status: 200)
    end)

    args = %{"user_id" => user.id, "count" => 2, "total" => "-40.00", "alert" => true}

    assert :ok = perform_job(SendNotification, args)

    assert_received {:pushed, body}
    assert %{"aps" => %{"alert" => %{"body" => "2 new transactions · $40.00"}}} = Jason.decode!(body)
  end
end
