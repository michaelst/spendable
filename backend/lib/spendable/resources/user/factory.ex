defmodule Spendable.User.Factory do
  def default() do
    %{
      firebase_id: Ecto.UUID.generate(),
      bank_limit: 10
    }
  end
end
