defmodule SpendableWeb.Live.Budgets.SwiftUI do
  use LiveViewNative.Component,
    format: :swiftui,
    as: :render

  def render(assigns, _interface) do
    ~LVN"""
    <List>
      <Text :for={budget <- @budgets}><%= budget.name %></Text>
    </List>
    """
  end
end
