defmodule Spendable.Tag.Factory do
  defmacro __using__(_opts) do
    quote do
      def tag_factory do
        %Spendable.Tag{
          name: "My Tag"
        }
      end
    end
  end
end
