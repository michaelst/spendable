defmodule Spendable.Banks.Member.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Spendable.Banks.Member
  alias Spendable.Banks.Member.Resolver
  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Middleware.LoadModel

  object :bank_member do
    field :id, non_null(:id)
    field :external_id, non_null(:string)
    field :institution_id, :string
    field :logo, :string
    field :name, non_null(:string)
    field :provider, non_null(:string)
    field :status, :string
    field :bank_accounts, :bank_account |> non_null |> list_of |> non_null, resolve: dataloader(Spendable)

    field :plaid_link_token, non_null(:string) do
      complexity(50)

      resolve(fn member, _args, _resolution ->
        with {:ok, %{body: %{"link_token" => token}}} <- Plaid.create_link_token(member.user_id, member.plaid_token) do
          {:ok, token}
        end
      end)
    end
  end

  object :bank_member_queries do
    field :bank_members, :bank_member |> non_null |> list_of |> non_null do
      middleware(CheckAuthentication)
      resolve(&Resolver.list/2)
    end

    field :bank_member, non_null(:bank_member) do
      middleware(CheckAuthentication)
      middleware(LoadModel, module: Member)
      arg(:id, non_null(:id))
      resolve(&Resolver.get/2)
    end
  end

  object :bank_member_mutations do
    field :create_bank_member, non_null(:bank_member) do
      middleware(CheckAuthentication)
      arg(:public_token, non_null(:string))
      resolve(&Resolver.create/2)
    end
  end
end
