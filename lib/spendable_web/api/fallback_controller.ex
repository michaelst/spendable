defmodule SpendableWeb.Api.FallbackController do
  use SpendableWeb, :controller

  @conflicts [
    :already_archived,
    :already_transferred,
    :bank_limit_reached,
    :identity_already_linked,
    :identity_claimed,
    :last_identity,
    :not_a_transfer,
    :not_supported,
    :transfer_not_allowed
  ]

  def call(conn, {:error, :unauthenticated}) do
    send_error(conn, :unauthorized, :unauthenticated)
  end

  # A rejected ID token is a failed sign-in, not a bad request: the client has to authenticate again.
  def call(conn, {:error, :invalid_id_token}) do
    send_error(conn, :unauthorized, :invalid_id_token)
  end

  def call(conn, {:error, :not_authorized}) do
    send_error(conn, :forbidden, :not_authorized)
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    errors =
      changeset
      |> Ecto.Changeset.traverse_errors(&translate_error/1)
      |> flatten_errors("")

    send_errors(conn, :unprocessable_entity, errors)
  end

  # An error this does not name is a bug rather than a response, so it crashes into a 500.
  def call(conn, {:error, code}) when is_atom(code) do
    cond do
      code in @conflicts -> send_error(conn, :conflict, code)
      String.ends_with?(Atom.to_string(code), "_not_found") -> send_error(conn, :not_found, code)
    end
  end

  defp send_error(conn, status, code) do
    send_errors(conn, status, [%{code: code, detail: detail(code)}])
  end

  defp send_errors(conn, status, errors) do
    conn
    |> put_status(status)
    |> json(%{errors: errors})
  end

  defp detail(code) do
    code |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()
  end

  defp translate_error({message, opts}) do
    Regex.replace(~r"%{(\w+)}", message, fn _whole, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end

  # Nested changesets (a transaction's allocations, a split's lines) come back as lists of maps,
  # so the pointer has to carry the index that failed.
  defp flatten_errors(errors, prefix) when is_map(errors) do
    Enum.flat_map(errors, fn {field, value} -> flatten_errors(value, "#{prefix}/#{field}") end)
  end

  defp flatten_errors(errors, prefix) when is_list(errors) do
    errors
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {message, _index} when is_binary(message) ->
        [%{code: :invalid, detail: message, source: %{pointer: prefix}}]

      {nested, index} ->
        flatten_errors(nested, "#{prefix}/#{index}")
    end)
  end
end
