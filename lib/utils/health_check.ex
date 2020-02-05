defmodule HealthCheck do
  @moduledoc """
  Generic health check endpoint for Phoenix/Plug web apps.
  You can provide an optional `resp_body` argument when mounting the plug that will override the default response body.
  Usage:
    Include within your phoenix router.ex file
    `forward "/_health", HealthCheckup, resp_body: "I'm up!"`
  Example:
    GET /_health
    HTTP/1.1 200 OK
    I'm up!
  """

  import Plug.Conn

  @type options :: [resp_body: String.t()]

  @resp_body "ok"

  @spec init(options) :: options
  def init(opts \\ []) do
    [resp_body: opts[:resp_body] || @resp_body]
  end

  @spec call(Plug.Conn.t(), options) :: Plug.Conn.t()
  def call(%Plug.Conn{} = conn, opts) do
    send_resp(conn, 200, opts[:resp_body])
  end
end
