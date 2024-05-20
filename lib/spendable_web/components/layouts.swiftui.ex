defmodule SpendableWeb.Layouts.SwiftUI do
  use SpendableNative, [:layout, format: :swiftui]

  embed_templates "layouts_swiftui/*"
end
