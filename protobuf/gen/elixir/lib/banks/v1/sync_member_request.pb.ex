defmodule Banks.V1.SyncMemberRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :member_id, 1, type: :string, json_name: "memberId"
end