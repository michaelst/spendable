defmodule SpendableWeb.Live.Login.SwiftUI do
  use LiveViewNative.Component, format: :swiftui

  def render(assigns, _interface) do
    ~LVN"""
    <GoogleSignInButton onSignIn="google_signin"/>
    """
  end
end
