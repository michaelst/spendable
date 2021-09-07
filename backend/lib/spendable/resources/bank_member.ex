defmodule Spendable.BankMember do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshGraphql.Resource
    ]

  postgres do
    repo(Spendable.Repo)
    table "bank_members"
  end

  attributes do
    integer_primary_key :id

    attribute :external_id, :string, allow_nil?: false
    attribute :institution_id, :string
    attribute :logo, :string
    attribute :name, :string, allow_nil?: false
    attribute :plaid_token, :string, allow_nil?: false
    attribute :provider, :string, allow_nil?: false
    attribute :status, :string

    timestamps()
  end

  identities do
    identity :external_id, [:external_id]
  end

  # plaid link token calculation
  # resolve(fn member, _args, _resolution ->
  #   with {:ok, %{body: %{"link_token" => token}}} <- Plaid.create_link_token(member.user_id, member.plaid_token) do
  #     {:ok, token}
  #   end
  # end)

  relationships do
    belongs_to :user, Spendable.User, required?: true, field_type: :integer
    has_many :bank_accounts, Spendable.BankAccount
  end

  graphql do
    type :bank_member

    queries do
      get :bank_member, :read
      list :bank_members, :read
    end

    mutations do
      update :update_bank_account, :update
    end

    # create mutation to turn on/off sync
    #field :create_bank_member, non_null(:bank_member) do
    #  middleware(CheckAuthentication)
    #  arg(:public_token, non_null(:string))
    #  resolve(&Resolver.create/2)

    # count = from(Member, where: [user_id: ^user.id]) |> Repo.aggregate(:count, :id)
#
    # if count < user.bank_limit do
    #   {:ok, %{body: %{"access_token" => token}}} = Plaid.exchange_public_token(token)
    #   Logger.info("New plaid member token: #{token}")
    #   {:ok, %{body: details}} = Plaid.item(token)
#
    #   %Member{plaid_token: token}
    #   |> Member.changeset(Adapter.format(details, user.id, :member))
    #   |> Repo.insert()
    #   |> case do
    #     {:ok, member} ->
    #       SyncMember.sync_accounts(member)
    #       {:ok, %{status: 200}} = SyncMemberRequest.publish(member.id)
    #       {:ok, member}
#
    #     result ->
    #       result
    #   end
    # else
    #   {:error, "Bank limit reached"}
    # end
  end
end
