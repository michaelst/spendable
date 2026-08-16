defmodule SpendableWeb.Api.ErrorRenderer do
  @moduledoc false
  @behaviour Plug

  alias OpenApiSpex.OpenApi
  alias Plug.Conn

  @impl Plug
  def init(errors), do: errors

  @impl Plug
  def call(conn, errors) do
    body = OpenApi.json_encoder().encode!(%{errors: Enum.map(errors, &render/1)})

    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(422, body)
  end

  defp render(error) do
    %{
      code: :invalid,
      detail: to_string(error),
      source: %{pointer: OpenApiSpex.path_to_string(error)}
    }
  end
end
