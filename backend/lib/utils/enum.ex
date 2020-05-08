defmodule Spendable.Utils.Enum do
  @moduledoc """
  Sets up EctoEnum and a GraphQL Enum.

  Accepts a type and values opt. Type is the GraphQL enum type and values contains a list of maps defining the values.

  ## Defining Values:
  The only required field in a value is name.

  You can also define the fields `as`, `deprecate`, `description` for the absinthe enum notation.

  By default we store the string version of `name` as the database value, however, you can specify a `db_value` option to override that.

  ```
  type: :notification_provider,
  values: [
    %{name: :apns, as: :something_else, deprecate: "This is why this is deprecated", description: "Describe the field"},
    ...
  ]
  ```
  """

  defmacro __using__(opts) do
    values = Enum.map(opts[:values] || [], fn {_, _, list} -> list end)

    quote do
      use EctoEnum, unquote(Enum.map(values, &{&1[:name], &1[:db_value] || "#{&1[:name]}"}))
      use Absinthe.Schema.Notation

      enum unquote(opts[:type]) do
        unquote do
          for item <- values do
            quote do
              value(
                unquote(item[:name]),
                unquote(as: item[:as] || item[:name], deprecate: item[:deprecate], description: item[:description])
              )
            end
          end
        end
      end
    end
  end
end
