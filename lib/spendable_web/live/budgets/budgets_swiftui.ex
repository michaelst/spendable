defmodule SpendableWeb.Live.Budgets.SwiftUI do
  use LiveViewNative.Component,
    format: :swiftui

  def render(assigns, _interface) do
    ~LVN"""
    <VStack>
      <List>
        <Text :for={budget <- @budgets}><%= budget.name %></Text>
      </List>
      <RequestFinanceKitAuthorization onAccountsSynced="accounts_synced" />
    </VStack>
    """
  end
end
