# Mints the signed session cookie the app would have set after a successful Google sign-in, so a
# headless browser can authenticate without an OAuth round trip and without anyone typing a
# password. Run with: mix run session_cookie.exs [user id or external_id]
#
# Prints:
#   SESSION_COOKIE <cookie name> <cookie value>
#   SESSION_USER <user id>
import Ecto.Query

alias Plug.Session.COOKIE
alias Spendable.Accounts.Schemas.User

# Read the cookie name and salt out of the endpoint rather than duplicating them here, so this
# script cannot quietly drift out of sync with the app it is signing in to.
endpoint_source = File.read!("lib/spendable_web/endpoint.ex")

extract = fn option ->
  case Regex.run(~r/#{option}:\s*"([^"]+)"/, endpoint_source) do
    [_match, value] -> value
    nil -> raise "could not find #{option} in lib/spendable_web/endpoint.ex"
  end
end

key = extract.("key")
signing_salt = extract.("signing_salt")

secret_key_base =
  :spendable
  |> Application.fetch_env!(SpendableWeb.Endpoint)
  |> Keyword.fetch!(:secret_key_base)

# The dev database has no fixed admin, and users carry no email - they are whoever has signed in
# with Google on this machine. Take the one named, or the oldest one there is.
user =
  case System.argv() do
    [identifier | _rest] ->
      Spendable.Repo.one(
        from user in User, where: user.id == ^identifier or user.external_id == ^identifier
      ) || raise "no user with id or external_id #{identifier}"

    [] ->
      Spendable.Repo.one(from user in User, order_by: [asc: user.inserted_at], limit: 1) ||
        raise "the dev database has no users - sign in through Google once at http://localhost:4000"
  end

cookie =
  COOKIE.put(
    %Plug.Conn{secret_key_base: secret_key_base},
    nil,
    %{"current_user_id" => user.id},
    COOKIE.init(signing_salt: signing_salt, log: false)
  )

IO.puts("SESSION_COOKIE #{key} #{cookie}")
IO.puts("SESSION_USER #{user.id}")
