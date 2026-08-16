defmodule Spendable.Accounts.Actions.DeliverNotification do
  @moduledoc false

  import Ecto.Query

  alias Spendable.Accounts.Clients.Apns
  alias Spendable.Accounts.Schemas.ApiToken
  alias Spendable.Repo

  require Logger

  # A token APNs names as dead will never work again, so the row is cleared instead of retried.
  @dead_token_reasons ["BadDeviceToken", "DeviceTokenNotForTopic", "Unregistered"]

  @doc """
  Pushes to every device the user has registered. Takes an id rather than a scope because the only
  caller is the job queue, which carries ids.

  Every completed sync pushes, count or no count: the silent half is the only signal the app gets
  that a sync it asked for has finished.
  """
  def deliver_notification(user_id, %{count: count, total: total, alert: alert})
      when is_binary(user_id) do
    message = build_message(count, total, alert)

    query =
      from api_token in ApiToken,
        where: api_token.user_id == ^user_id,
        where: not is_nil(api_token.apns_token)

    query
    |> Repo.all()
    |> Enum.map(&push(&1, message))
    |> Enum.find(:ok, &match?({:error, _reason}, &1))
  end

  defp push(%ApiToken{} = api_token, {payload, headers}) do
    case Apns.push(api_token.apns_token, payload, headers) do
      {:ok, %Tesla.Env{status: 200}} ->
        :ok

      {:ok, %Tesla.Env{body: %{"reason" => reason}}} when reason in @dead_token_reasons ->
        Logger.info("APNs rejected a device: #{reason}")

        {:ok, _cleared} = api_token |> ApiToken.changeset(%{apns_token: nil}) |> Repo.update()

        :ok

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, "APNs returned #{status}: #{inspect(body)}"}

      {:error, :not_configured} ->
        :ok
    end
  end

  defp build_message(count, total, true) when count > 0 do
    noun = if count == 1, do: "transaction", else: "transactions"
    amount = total |> Decimal.abs() |> Decimal.round(2) |> Decimal.to_string(:normal)

    payload = %{
      aps: %{
        alert: %{title: "Spendable", body: "#{count} new #{noun} · $#{amount}"},
        "content-available": 1,
        sound: "default"
      }
    }

    {payload, [{"apns-push-type", "alert"}, {"apns-priority", "10"}]}
  end

  defp build_message(_count, _total, _alert) do
    {%{aps: %{"content-available": 1}}, [{"apns-push-type", "background"}, {"apns-priority", "5"}]}
  end
end
