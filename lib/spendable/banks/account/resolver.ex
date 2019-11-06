defmodule Spendable.Banks.Account.Resolver do
  alias Spendable.Banks.Account
  alias Spendable.Repo

  def update(params, %{context: %{model: model}}) do
    model
    |> Account.changeset(params)
    |> Repo.update()
  end
end
