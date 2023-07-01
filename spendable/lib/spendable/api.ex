defmodule Spendable.Api do
  use Ash.Api

  resources do
    registry Spendable.Registry
  end
end
