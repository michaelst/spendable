defmodule SpendableWeb.Utils.ToolReply do
  @moduledoc "Import this module rather than aliasing it."

  alias Anubis.Server.Response

  @doc "Replies to an MCP tool call with structured JSON the client can also read as text."
  def reply(frame, data), do: {:reply, Response.structured(Response.tool(), data), frame}

  @doc """
  Replies with a failure the caller can act on rather than a crash: changeset errors become one
  readable line per field, and a context's error atom becomes its own words.
  """
  def reply_error(frame, %Ecto.Changeset{} = changeset) do
    message =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {message, opts} ->
        Regex.replace(~r"%{(\w+)}", message, fn _match, key ->
          opts |> Keyword.get(String.to_existing_atom(key), "") |> to_string()
        end)
      end)
      |> describe()

    reply_error(frame, message)
  end

  def reply_error(frame, reason) when is_atom(reason) do
    reply_error(frame, reason |> to_string() |> String.replace("_", " "))
  end

  def reply_error(frame, message) when is_binary(message) do
    {:reply, Response.error(Response.tool(), message), frame}
  end

  # Errors on a nested association come back as a list of maps, one per child, so this recurses
  # rather than assuming every value is a list of strings.
  defp describe(errors) when is_map(errors) do
    Enum.map_join(errors, "; ", fn {field, messages} -> "#{field} #{describe(messages)}" end)
  end

  defp describe(messages) when is_list(messages) do
    messages |> Enum.reject(&(&1 == %{})) |> Enum.map_join(", ", &describe/1)
  end

  defp describe(message) when is_binary(message), do: message
end
