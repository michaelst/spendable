defmodule Spendable.User.Types do
  use Absinthe.Schema.Notation

  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.User.Resolver
  alias Spendable.User.Utils

  object :user do
    field :id, non_null(:id)
    field :bank_limit, non_null(:integer)

    field :spendable, non_null(:decimal) do
      complexity(50)

      resolve(fn user, _args, _resolution ->
        {:ok, Utils.calculate_spendable(user)}
      end)
    end

    field :plaid_link_token, non_null(:string) do
      complexity(50)

      resolve(fn user, _args, _resolution ->
        with {:ok, %{body: %{"link_token" => token}}} <- Plaid.create_link_token(user.id) do
          {:ok, token}
        end
      end)
    end
  end

  object :user_queries do
    field :current_user, non_null(:user) do
      middleware(CheckAuthentication)
      resolve(&Resolver.current_user/2)
    end
  end

  object :user_mutations do
  end
end
