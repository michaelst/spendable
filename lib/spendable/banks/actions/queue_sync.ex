defmodule Spendable.Banks.Actions.QueueSync do
  @moduledoc false

  alias Spendable.Banks.Jobs.SyncMember
  alias Spendable.Banks.Schemas.BankMember

  @doc """
  Syncing talks to Plaid for as long as it takes, so it never runs in the request.
  Pass `:start_date` to reach further back than the sync's default window, and `notify: false` to
  hold back the alert on a run whose size would make it noise.
  """
  def queue_sync(%BankMember{} = bank_member, opts \\ []) do
    %{bank_member_id: bank_member.id}
    |> put_start_date(opts[:start_date])
    |> put_notify(opts[:notify])
    |> SyncMember.new()
    |> Oban.insert()
  end

  defp put_start_date(args, %Date{} = start_date), do: Map.put(args, :start_date, start_date)
  defp put_start_date(args, _start_date), do: args

  defp put_notify(args, false), do: Map.put(args, :notify, false)
  defp put_notify(args, _notify), do: args
end
