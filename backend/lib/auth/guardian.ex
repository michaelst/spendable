defmodule Spendable.Auth.Guardian do
  use Guardian, otp_app: :spendable

  alias Spendable.Api
  alias Spendable.Repo
  alias Spendable.User

  def subject_for_token(resource, _claims) do
    {:ok, resource.firebase_id}
  end

  def resource_from_claims(%{"sub" => firebase_id}) do
    Repo.get_by(User, firebase_id: firebase_id)
    |> maybe_create_user(firebase_id)
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  defp maybe_create_user(%User{} = user, _firebase_id) do
    {:ok, user}
  end

  defp maybe_create_user(nil, firebase_id) do
    Ash.Changeset.new(User, %{firebase_id: firebase_id})
    |> Api.create()
  end
end
