defmodule Spendable.Accounts.Clients.ApnsTest do
  # Not async: the unconfigured case is the absence of application config, which is global.
  use Spendable.DataCase, async: false

  alias Spendable.Accounts.Clients.Apns

  @device_token String.duplicate("ab", 32)
  @payload %{aps: %{"content-available": 1}}

  setup do
    configured = Application.get_env(:spendable, Apns)

    on_exit(fn -> Application.put_env(:spendable, Apns, configured) end)

    %{configured: configured}
  end

  test "signs the request with a provider token for the topic" do
    expect(TeslaMock, :call, fn %{method: :post, url: url, headers: headers}, _opts ->
      send(self(), {:pushed, url, headers})

      TeslaHelper.response(status: 200)
    end)

    assert {:ok, %Tesla.Env{status: 200}} = Apns.push(@device_token, @payload, [])

    assert_received {:pushed, url, headers}
    assert url == "https://api.push.apple.com/3/device/#{@device_token}"
    assert {"apns-topic", "fiftysevenmedia.Spendable"} in headers
    assert {_authorization, "bearer " <> _jwt} = List.keyfind(headers, "authorization", 0)
  end

  test "passes the caller's headers through" do
    expect(TeslaMock, :call, fn %{headers: headers}, _opts ->
      send(self(), {:pushed, headers})

      TeslaHelper.response(status: 200)
    end)

    {:ok, _env} = Apns.push(@device_token, @payload, [{"apns-push-type", "background"}])

    assert_received {:pushed, headers}
    assert {"apns-push-type", "background"} in headers
  end

  # APNs rejects a provider token minted more than once every twenty minutes.
  test "reuses one provider token across pushes" do
    stub(TeslaMock, :call, fn %{headers: headers}, _opts ->
      send(self(), {:pushed, List.keyfind(headers, "authorization", 0)})

      TeslaHelper.response(status: 200)
    end)

    {:ok, _first} = Apns.push(@device_token, @payload, [])
    {:ok, _second} = Apns.push(@device_token, @payload, [])

    assert_received {:pushed, authorization}
    assert_received {:pushed, ^authorization}
  end

  test "refuses to send when no signing key is configured", %{configured: configured} do
    Application.put_env(:spendable, Apns, Keyword.delete(configured, :private_key))

    assert {:error, :not_configured} = Apns.push(@device_token, @payload, [])
  end
end
