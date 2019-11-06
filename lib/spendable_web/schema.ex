defmodule Spendable.Web.Schema do
  use Absinthe.Schema

  import_types(Spendable.Auth.Types)
  import_types(Spendable.User.Types)
  import_types(Spendable.Banks.Member.Types)
  import_types(Spendable.Banks.Account.Types)

  query do
    field :health, :string, resolve: fn _, _ -> {:ok, "up"} end
    import_fields(:bank_member_queries)
  end

  mutation do
    import_fields(:auth_queries)
    import_fields(:user_queries)
    import_fields(:bank_member_mutations)
    import_fields(:bank_account_mutations)
  end

  def context(context) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Spendable, Spendable.data())

    Map.put(context, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Spendable.Middleware.ChangesetErrors]
  end

  # if it's any other object keep things as is
  def middleware(middleware, _field, _object), do: middleware
end
