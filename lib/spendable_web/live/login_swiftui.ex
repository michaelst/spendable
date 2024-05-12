defmodule SpendableWeb.Live.Login.SwiftUI do
  use LiveViewNative.Component,
    format: :swiftui,
    as: :render

  def render(assigns, _interface) do
    ~LVN"""
    <GoogleSignInButton />
    """
  end
end
