defmodule SpendableWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use SpendableWeb, :controller
      use SpendableWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths(), do: ["assets", "fonts", "images", "favicon.svg", "mask-icon.svg", "robots.txt"]

  def router() do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def controller() do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: SpendableWeb.Layouts]

      import Plug.Conn
      use Gettext, backend: SpendableWeb.Gettext

      unquote(verified_routes())
    end
  end

  def api_controller() do
    quote do
      use Phoenix.Controller, formats: [:json]
      use OpenApiSpex.ControllerSpecs

      import Plug.Conn

      # replace_params: false keeps params string-keyed so they go straight into a changeset, and
      # so an omitted field stays distinguishable from one explicitly set to null.
      plug OpenApiSpex.Plug.CastAndValidate,
        json_render_error_v2: true,
        replace_params: false,
        render_error: SpendableWeb.Api.ErrorRenderer

      action_fallback SpendableWeb.Api.FallbackController
    end
  end

  def live_view() do
    quote do
      use Phoenix.LiveView,
        layout: {SpendableWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def html() do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  def verified_routes() do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: SpendableWeb.Endpoint,
        router: SpendableWeb.Router,
        statics: SpendableWeb.static_paths()
    end
  end

  defp html_helpers() do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import SpendableWeb.CoreComponents
      use Gettext, backend: SpendableWeb.Gettext
      import SpendableWeb.Utils.SocketReplies

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
