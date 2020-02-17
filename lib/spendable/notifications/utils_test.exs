defmodule Spendable.Notifications.UtilsTest do
  use Spendable.DataCase, async: true
  import Spendable.Factory

  alias Spendable.Notifications.Utils

  test "send apns notification" do
    {user, _} = Spendable.TestUtils.create_user()
    insert(:device_token, user: user, device_token: "test")

    assert_raise RuntimeError, "device_tokens must be preloaded", fn ->
      Utils.send(user, "title", "body")
    end

    user = Spendable.Repo.preload(user, :device_tokens)
    Utils.send(user, "title", "body")
  end
end
