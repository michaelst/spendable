defmodule Spendable.Banks.Account.Resolver do
  alias Spendable.Banks.Account
  alias Spendable.Publishers.SyncMemberRequest
  alias Spendable.Repo

  def update(params, %{context: %{model: model}}) do
    model
    |> Account.changeset(params)
    |> Repo.update()
    |> case do
      {:ok, %{sync: true} = model} = response ->
        {:ok, %{status: 200}} = SyncMemberRequest.publish(model.bank_member_id)
        response

      response ->
        response
    end
  end
end
