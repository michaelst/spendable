defmodule SyncMemberRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field :member_id, 1, type: :int64, json_name: "memberId"
end
defmodule SendNotificationRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.10.0", syntax: :proto3

  field :user_id, 1, type: :int64, json_name: "userId"
  field :title, 2, type: :string
  field :body, 3, type: :string
end
