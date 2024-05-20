defmodule SpendableWeb.Live.Login do
  use SpendableWeb, :live_view

  alias Spendable.User

  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  def handle_event("google_signin", %{"id_token" => id_token}, socket) do
    client_id = Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)[:client_id]

    case Spendable.Guardian.decode_and_verify(id_token, %{"aud" => client_id}) do
      {:ok, %{"sub" => uid}} ->
        user =
          User
          |> Ash.Changeset.new(%{
            external_id: uid,
            provider: "google"
          })
          |> Spendable.Api.create!(upsert?: true, upsert_identity: :external_id)

        token = SpendableWeb.Live.UserAuth.generate_token(user.id)

        {:noreply, push_redirect(socket, to: ~p"/budgets?token=#{token}", replace: true)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end
end
