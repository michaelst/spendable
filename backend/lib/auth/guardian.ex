defmodule Spendable.Auth.Guardian do
  use Guardian, otp_app: :spendable

  import Ecto.Query

  alias Spendable.Repo
  alias Spendable.User

  def subject_for_token(resource, _claims) do
    {:ok, resource.firebase_id}
  end

  def resource_from_claims(%{
        "sub" => firebase_id,
        "firebase" => %{"identities" => %{"apple.com" => [apple_identifier]}}
      }) do
    query = from u in User, where: u.apple_identifier == ^apple_identifier or u.firebase_id == ^firebase_id

    query
    |> Repo.one()
    |> maybe_create_user(firebase_id)
  end

  def resource_from_claims(%{"sub" => firebase_id}) do
    Repo.get_by(User, firebase_id: firebase_id)
    |> maybe_create_user(firebase_id)
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  defp maybe_create_user(%User{} = user, firebase_id) do
    # need to make sure users get firebase id set
    user
    |> User.changeset(%{firebase_id: firebase_id})
    |> Repo.update()
  end

  defp maybe_create_user(nil, firebase_id) do
    %User{}
    |> User.changeset(%{firebase_id: firebase_id})
    |> Repo.insert()
  end
end
