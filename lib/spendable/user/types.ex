defmodule Spendable.User.Types do
  use Absinthe.Schema.Notation
  import Ecto.Query, only: [from: 2]

  alias Spendable.Banks.Account
  alias Spendable.Budgets.Allocation
  alias Spendable.Budgets.Budget
  alias Spendable.Middleware.CheckAuthentication
  alias Spendable.Repo
  alias Spendable.User.Resolver

  object :user do
    field :id, :id
    field :bank_limit, :integer
    field :email, :string
    field :token, :string

    field :spendable, :string do
      complexity(50)

      resolve(fn user, _, _ ->
        balance =
          from(ba in Account,
            select:
              fragment(
                "CASE WHEN ? = 'credit' THEN ? * -1 ELSE COALESCE(?, ?) END ",
                ba.type,
                ba.balance,
                ba.available_balance,
                ba.balance
              ),
            where: ba.user_id == ^user.id and ba.sync
          )
          |> Repo.one()
          |> Kernel.||("0.00")

        adjustments =
          from(b in Budget,
            select: sum(b.adjustment),
            where: b.user_id == ^user.id
          )
          |> Repo.one()
          |> Kernel.||("0.00")

        spendable =
          from(a in Allocation,
            join: b in assoc(a, :budget),
            where: b.user_id == ^user.id,
            select: {b.id, sum(a.amount)},
            group_by: b.id
          )
          |> Repo.all()
          |> Enum.reduce(Decimal.sub(balance, adjustments), fn {_id, allocated}, acc ->
            # we subtract the absolute value because budgets that are negative are missing
            # allocated funds needed to be 0 so it needs to be subtracted from the balance
            # otherwise a negative budget could increase your spendable amount incorrectly
            Decimal.sub(acc, Decimal.abs(allocated))
          end)

        {:ok, spendable}
      end)
    end
  end

  object :user_queries do
    field :current_user, :user do
      middleware(CheckAuthentication)
      resolve(&Resolver.current_user/2)
    end
  end

  object :user_mutations do
    field :create_user, :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolver.create/2)
    end

    field :update_user, :user do
      middleware(CheckAuthentication)
      arg(:email, non_null(:string))
      arg(:password, :string)
      resolve(&Resolver.update/2)
    end
  end
end
