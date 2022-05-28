defmodule Spendable.Web.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :spendable

  plug Spandex.Plug.StartTrace

  plug(CORSPlug)

  plug(Plug.Static,
    at: "/",
    from: :spendable,
    gzip: true,
    only: ~w(
      css
      fonts
      images
      js
      favicon.ico
      favicon-16x16.png
      favicon-32x32.png
      android-chrome-192x192.png
      android-chrome-512x512.png
      apple-touch-icon.png
      robots.txt
      site.webmanifest
    )
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug Sentry.PlugContext

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(Plug.Session,
    store: :cookie,
    key: "_spendable_key",
    signing_salt: "kJiN34/t"
  )

  plug(Spendable.Web.Router)

  plug Spandex.Plug.AddContext
  plug Spandex.Plug.EndTrace
end
