defmodule Spendable.Api do
  use Ash.Api, extensions: [
    AshGraphql.Api
  ]

  resources do
    resource Spendable.User
  end
end
