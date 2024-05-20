defmodule SpendableNative do
  import SpendableWeb, only: [verified_routes: 0]

  def live_view() do
    quote do
      use LiveViewNative.LiveView,
        formats: [
          :swiftui
        ],
        layouts: [
          swiftui: {SpendableWeb.Layouts.SwiftUI, :app}
        ]

      unquote(verified_routes())
    end
  end

  def render_component(opts) do
    opts =
      opts
      |> Keyword.take([:format])
      |> Keyword.put(:as, :render)

    quote do
      use LiveViewNative.Component, unquote(opts)

      unquote(helpers(opts[:format]))
    end
  end

  def component(opts) do
    opts = Keyword.take(opts, [:format, :root, :as])

    quote do
      use LiveViewNative.Component, unquote(opts)

      unquote(helpers(opts[:format]))
    end
  end

  def layout(opts) do
    opts = Keyword.take(opts, [:format, :root])

    quote do
      use LiveViewNative.Component, unquote(opts)

      import LiveViewNative.Component, only: [csrf_token: 1]

      unquote(helpers(opts[:format]))
    end
  end

  defp helpers(_format) do
    gettext_quoted =
      quote do
        import SpendableWeb.Gettext
      end

    [gettext_quoted, verified_routes()]
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__([which | opts]) when is_atom(which) do
    apply(__MODULE__, which, [opts])
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
