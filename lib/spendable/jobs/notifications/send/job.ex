defmodule Spendable.Jobs.Notifications.Send do
  import Ecto.Query, only: [from: 2]

  alias Spendable.Repo

  def perform(user_id, message) do
    from(Spendable.Notifications.Settings, where: [user_id: ^user_id, enabled: true])
    |> Repo.all()
    |> Enum.each(fn settings ->
      message
      |> Notifications.Provider.new!(settings)
      |> Notifications.Provider.push!()
      |> case do
        :ok -> :ok
        :invalid_token -> Repo.delete!(settings)
      end
    end)
  end
end
