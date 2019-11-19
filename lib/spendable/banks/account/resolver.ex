defmodule Spendable.Banks.Account.Resolver do
  alias Spendable.Banks.Account
  alias Spendable.Repo

  def update(params, %{context: %{model: model}}) do
    model
    |> Account.changeset(params)
    |> Repo.update()
    |> case do
      {:ok, %{sync: true} = model} = response ->
        {:ok, _} = Exq.enqueue(Exq, "default", Spendable.Jobs.Banks.SyncMember, [model.bank_member_id])
        response

      response ->
        response
    end
  end
end
