defmodule Spendable.Accounts.Actions.DeliverNotificationTest do
  # Not async: the unconfigured case is the absence of application config, which is global.
  use Spendable.DataCase, async: false

  alias Spendable.Accounts
  alias Spendable.Accounts.Clients.Apns
  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Scope

  @device_token String.duplicate("ab", 32)

  setup do
    {:ok, user} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    scope = Scope.for_user(user)

    {:ok, api_token} = Accounts.create_api_token(scope, %{})
    {:ok, api_token} = Accounts.register_apns_token(scope, api_token, @device_token)

    %{api_token: api_token, user: user}
  end

  test "tells the user what landed", %{user: user} do
    expect(TeslaMock, :call, fn %{body: body, headers: headers}, _opts ->
      send(self(), {:pushed, body, headers})

      TeslaHelper.response(status: 200)
    end)

    assert :ok =
             Accounts.deliver_notification(user.id, %{
               count: 3,
               total: Decimal.new("-84.21"),
               alert: true
             })

    assert_received {:pushed, body, headers}
    assert %{"aps" => %{"alert" => %{"body" => "3 new transactions · $84.21"}}} = Jason.decode!(body)
    assert {"apns-push-type", "alert"} in headers
    assert {"apns-priority", "10"} in headers
  end

  test "counts one transaction as one", %{user: user} do
    expect(TeslaMock, :call, fn %{body: body}, _opts ->
      send(self(), {:pushed, body})

      TeslaHelper.response(status: 200)
    end)

    :ok =
      Accounts.deliver_notification(user.id, %{
        count: 1,
        total: Decimal.new("-9.5"),
        alert: true
      })

    assert_received {:pushed, body}
    assert %{"aps" => %{"alert" => %{"body" => "1 new transaction · $9.50"}}} = Jason.decode!(body)
  end

  # The app has no other signal that a sync it asked for has finished.
  test "wakes the app when a sync found nothing", %{user: user} do
    expect(TeslaMock, :call, fn %{body: body, headers: headers}, _opts ->
      send(self(), {:pushed, body, headers})

      TeslaHelper.response(status: 200)
    end)

    :ok = Accounts.deliver_notification(user.id, %{count: 0, total: Decimal.new(0), alert: true})

    assert_received {:pushed, body, headers}
    assert %{"aps" => aps} = Jason.decode!(body)
    refute Map.has_key?(aps, "alert")
    assert {"apns-push-type", "background"} in headers
    assert {"apns-priority", "5"} in headers
  end

  test "stays silent about a run that was not the user's to hear about", %{user: user} do
    expect(TeslaMock, :call, fn %{body: body}, _opts ->
      send(self(), {:pushed, body})

      TeslaHelper.response(status: 200)
    end)

    :ok =
      Accounts.deliver_notification(user.id, %{
        count: 240,
        total: Decimal.new("-9000"),
        alert: false
      })

    assert_received {:pushed, body}
    assert %{"aps" => aps} = Jason.decode!(body)
    refute Map.has_key?(aps, "alert")
  end

  test "drops a device APNs says is gone", %{api_token: api_token, user: user} do
    expect(TeslaMock, :call, fn _env, _opts ->
      TeslaHelper.response(status: 410, body: %{"reason" => "Unregistered"})
    end)

    assert :ok = Accounts.deliver_notification(user.id, %{count: 0, total: Decimal.new(0), alert: true})

    assert %ApiToken{apns_token: nil} = Repo.get(ApiToken, api_token.id)
  end

  test "retries an APNs failure that is not the device's fault", %{user: user} do
    expect(TeslaMock, :call, fn _env, _opts ->
      TeslaHelper.response(status: 503, body: %{"reason" => "ServiceUnavailable"})
    end)

    assert {:error, _reason} =
             Accounts.deliver_notification(user.id, %{count: 0, total: Decimal.new(0), alert: true})
  end

  test "sends nothing to a user with no registered device" do
    {:ok, other} =
      Accounts.upsert_user_from_oauth(%{external_id: Ecto.UUID.generate(), provider: "google"})

    assert :ok = Accounts.deliver_notification(other.id, %{count: 0, total: Decimal.new(0), alert: true})
  end

  test "does nothing on a machine with no signing key", %{user: user} do
    configured = Application.get_env(:spendable, Apns)

    on_exit(fn -> Application.put_env(:spendable, Apns, configured) end)

    Application.put_env(:spendable, Apns, Keyword.delete(configured, :private_key))

    assert :ok = Accounts.deliver_notification(user.id, %{count: 0, total: Decimal.new(0), alert: true})
  end
end
