defmodule Spendable.Broadway.SyncMember do
  use Broadway
  import Ecto.Query, only: [from: 2]

  alias Broadway.Message
  alias Spendable.Banks.Account
  alias Spendable.Banks.Member
  alias Spendable.Banks.Providers.Plaid.Adapter
  alias Spendable.Banks.Transaction, as: BankTransaction
  alias Spendable.Publishers.SendNotificationRequest
  alias Spendable.Repo
  alias Spendable.Transaction

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

    Repo.get(Member, member_id)
    |> sync_member()
    |> sync_accounts()
    |> Enum.filter(& &1.sync)
    |> Enum.each(&sync_transactions/1)
  end

  defp sync_member(member) when is_struct(member) do
    {:ok, %{body: details}} = Plaid.item(member.plaid_token)

    member
    |> Member.changeset(Adapter.format(details, member.user_id, :member))
    |> Repo.update!()
  end

  defp sync_member(nil), do: :ok

  def sync_accounts(member) do
    case Plaid.accounts(member.plaid_token) do
      {:ok, %{body: %{"accounts" => accounts_details}}} ->
        Enum.map(accounts_details, fn account_details ->
          Repo.get_by(Account, user_id: member.user_id, external_id: account_details["account_id"])
          |> case do
            nil -> struct(Account)
            account -> account
          end
          |> Account.changeset(Adapter.format(account_details, member.id, member.user_id, :account))
          |> Repo.insert_or_update!()
          |> Map.put(:bank_member, member)
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
      %BankTransaction{}
      |> BankTransaction.changeset(Adapter.format(details, account.id, account.user_id, :bank_transaction))
      |> Repo.insert()
      |> case do
        {:ok, bank_transaction} ->
          %Transaction{}
          |> Transaction.changeset(Adapter.format(bank_transaction, :transaction))
          |> Repo.insert!()
          |> reassign_pending(details)

        {:error, error} ->
          Repo.rollback(error)
      end
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
    Repo.get_by(BankTransaction, external_id: pending_id, pending: true)
    |> Repo.preload(:transaction)
    |> case do
      %{transaction: %{id: pending_transasction_id}} = pending_bank_transaction ->
        from(Spendable.Budgets.Allocation, where: [transaction_id: ^pending_transasction_id])
        |> Repo.update_all(set: [transaction_id: transaction.id])

        Repo.delete!(pending_bank_transaction.transaction)
        Repo.delete!(pending_bank_transaction)

        transaction

      _nil_or_bank_transaction ->
        transaction
    end
  end

  defp reassign_pending(transaction, _details), do: transaction
end
