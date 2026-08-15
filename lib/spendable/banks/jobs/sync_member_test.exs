defmodule Spendable.Banks.Jobs.SyncMemberTest do
  use Spendable.DataCase, async: true

  alias Spendable.Banks.Jobs.SyncMember

  # The queue carries an id, so a member deleted between enqueue and run is not a crash.
  test "reports a member that no longer exists" do
    assert {:error, :bank_member_not_found} =
             perform_job(SyncMember, %{bank_member_id: "bkm_01M036GTQ48JXS0A2AXFNV6H5P"})
  end
end
