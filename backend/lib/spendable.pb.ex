defmodule SyncMemberRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          member_id: integer
        }

  defstruct [:member_id]

  field :member_id, 1, type: :int64
end

defmodule SendNotificationRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          user_id: integer,
          title: String.t(),
          body: String.t()
        }

  defstruct [:user_id, :title, :body]

  field :user_id, 1, type: :int64
  field :title, 2, type: :string
  field :body, 3, type: :string
end
