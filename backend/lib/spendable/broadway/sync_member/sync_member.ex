defmodule Spendable.Broadway.SyncMember do
  use Broadway

  import Ecto.Query

  alias Broadway.Message
  alias Spendable.BankAccount
  alias Spendable.BankMember
  alias Spendable.BankTransaction
  alias Spendable.Plaid.Adapter
  alias Spendable.Publishers.SendNotificationRequest
  alias Spendable.Transaction
  alias Spendable.Api
  alias Spendable.Repo

  require Ash.Query

  @producer if Application.compile_env(:spendable, :env) == :prod,
              do:
                {BroadwayCloudPubSub.Producer,
                 subscription: "projects/cloud-57/subscriptions/spendable.sync-member-request"},
              else: {Broadway.DummyProducer, []}

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: @producer
      ],
      processors: [
        default: []
      ],
      batchers: [
        default: [
          batch_size: 10,
          batch_timeout: 2_000
        ]
      ]
    )
  end

  def handle_message(_processor_name, message, _context) do
    Message.update_data(message, &process_data/1)
  end

  def handle_batch(_batch_name, messages, _batch_info, _context) do
    messages
  end

  defp process_data(data) do
    %SyncMemberRequest{member_id: member_id} = SyncMemberRequest.decode(data)

    BankMember
    |> Api.get(member_id, load: [:user])
    |> sync_member()
    |> sync_accounts()
    |> Enum.filter(& &1.sync)
    |> Enum.each(&sync_transactions/1)
  end

  defp sync_member({:ok, member}) do
    {:ok, %{body: details}} = Plaid.item(member.plaid_token)

    formatted_data = Adapter.bank_member(details)

    member
    |> Ash.Changeset.for_update(:update)
    |> Ash.Changeset.force_change_attributes(formatted_data)
    |> Api.update!()
  end

  defp sync_member(_result), do: :ok

  def sync_accounts(member) do
    case Plaid.accounts(member.plaid_token) do
      {:ok, %{body: %{"accounts" => accounts_details}}} ->
        Enum.map(accounts_details, fn account_details ->
          formatted_data = Adapter.bank_account(account_details)

          Api.get(BankAccount, user_id: member.user.id, external_id: account_details["account_id"])
          |> case do
            {:error, %Ash.Error.Query.NotFound{}} ->
              BankAccount
              |> Ash.Changeset.for_create(:create, formatted_data)
              |> Ash.Changeset.force_change_attributes(formatted_data)
              |> Ash.Changeset.replace_relationship(:bank_member, member)
              |> Ash.Changeset.replace_relationship(:user, member.user)
              |> Api.create!()

            {:ok, bank_account} ->
              bank_account
              |> Ash.Changeset.for_update(:update)
              |> Ash.Changeset.force_change_attributes(formatted_data)
              |> Ash.Changeset.replace_relationship(:bank_member, member)
              |> Ash.Changeset.replace_relationship(:user, member.user)
              |> Api.update!()
          end
        end)

      {:ok, %{body: %{"error_code" => "ITEM_LOGIN_REQUIRED"}}} ->
        []
    end
  end

  defp sync_transactions(account, opts \\ []) do
    count = opts[:count] || 500
    offset = opts[:offset] || 0
    cursor = offset + count

    case Plaid.account_transactions(account.bank_member.plaid_token, account.external_id, opts) do
      {:ok, %{body: %{"transactions" => transactions_details} = response}} ->
        Enum.each(transactions_details, fn transaction_details -> sync_transaction(transaction_details, account) end)

        with %{"total_transactions" => total} when total > cursor <- response do
          sync_transactions(account, Keyword.merge(opts, offset: cursor))
        end

      {:ok, %{body: %{"error_code" => "PRODUCT_NOT_READY"}}} ->
        :ok
    end
  end

  defp sync_transaction(details, account) do
    Repo.transaction(fn ->
      formatted_data = Adapter.bank_transaction(details)

      bank_transaction =
        BankTransaction
        |> Ash.Changeset.for_create(:create, formatted_data)
        |> Ash.Changeset.replace_relationship(:bank_account, account)
        |> Ash.Changeset.replace_relationship(:user, account.user)
        |> Ash.Changeset.force_change_attributes(formatted_data)
        |> Api.create!()

      formatted_data = Adapter.transaction(bank_transaction)

      Transaction
      |> Ash.Changeset.for_create(:private_create, formatted_data)
      |> Ash.Changeset.replace_relationship(:bank_transaction, bank_transaction)
      |> Ash.Changeset.replace_relationship(:user, account.user)
      |> Ash.Changeset.force_change_attributes(formatted_data)
      |> Api.create!()
      |> reassign_pending(details)
    end)
    |> case do
      {:ok, transaction} = response ->
        # if pending transaction id is set that means we have already sent a notification for the pending transaction
        if is_nil(details["pending_transaction_id"]) do
          {:ok, %{status: 200}} =
            SendNotificationRequest.publish(
              account.user_id,
              transaction.name,
              "$#{Decimal.abs(transaction.amount)}"
            )
        end

        response

      response ->
        response
    end
  end

  defp reassign_pending(transaction, %{"pending_transaction_id" => pending_id}) when is_binary(pending_id) do
    BankTransaction
    |> Ash.Query.filter(external_id: pending_id, pending: true)
    |> Ash.Query.load(:transaction)
    |> Api.read_one()
    |> case do
      {:ok, %{transaction: %{id: pending_transasction_id}} = pending_bank_transaction} ->
        from(Spendable.BudgetAllocation, where: [transaction_id: ^pending_transasction_id])
        |> Repo.update_all(set: [transaction_id: transaction.id])

        Repo.delete!(pending_bank_transaction.transaction)
        Repo.delete!(pending_bank_transaction)

        transaction

      _not_found_or_bank_transaction ->
        transaction
    end
  end

  defp reassign_pending(transaction, _details), do: transaction
end
