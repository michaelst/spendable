defmodule Spendable.Api do
  use Ash.Api

  resources do
    resource Spendable.User
  end
end
