defmodule Spendable.User.Factory do
  defmacro __using__(_opts) do
    quote do
      def user_factory() do
        %Spendable.User{
          firebase_id: Ecto.UUID.generate(),
          bank_limit: 10
        }
      end
    end
  end
end
