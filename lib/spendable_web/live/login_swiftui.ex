defmodule SpendableWeb.Live.Login.SwiftUI do
  use LiveViewNative.Component,
    format: :swiftui,
    as: :render

  def render(assigns, _interface) do
    ~LVN"""
    <GoogleSignInButton />
    """
  end

  def handle_event("google_sign_in", %{"id_token" => id_token}, socket) do
    client_id = Application.get_env(:ueberauth, Ueberauth.Strategy.Google.OAuth)[:client_id]

    case Spendable.Guardian.decode_and_verify(id_token, %{"aud" => client_id}) do
      {:ok, %{"picture" => image, "sub" => uid}} ->
        user =
          User
          |> Ash.Changeset.new(%{
            external_id: uid,
            provider: "google",
            image: image
          })
          |> Spendable.Api.create!(upsert?: true, upsert_identity: :external_id)

        {:noreply, assign(socket, current_user: user)}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end
end
