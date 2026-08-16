defmodule SpendableWeb.Api.BankAccountController do
  use SpendableWeb, :api_controller

  alias Spendable.Banks
  alias SpendableWeb.Api.Schemas.BankAccount
  alias SpendableWeb.Api.Schemas.BankAccountRequest
  alias SpendableWeb.Api.Schemas.Errors

  tags ["banks"]

  operation :update,
    operation_id: "updateBankAccount",
    summary: "Sync an account, or assign it to a budget",
    parameters: [id: [in: :path, type: :string, required: true]],
    request_body: {"BankAccount", "application/json", BankAccountRequest},
    responses: [
      ok: {"BankAccount", "application/json", BankAccount},
      not_found: {"Errors", "application/json", Errors},
      unprocessable_entity: {"Errors", "application/json", Errors}
    ]

  def update(conn, %{"id" => id} = params) do
    scope = conn.assigns.current_scope

    with {:ok, account} <- Banks.get_bank_account(scope, id),
         {:ok, updated} <- Banks.update_bank_account(scope, account, Map.delete(params, "id")) do
      json(conn, BankAccount.build(updated))
    end
  end
end
