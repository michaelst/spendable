defmodule SpendableWeb.Utils.AccountLabel do
  @moduledoc "Import this module rather than aliasing it."

  @doc """
  An account reads as its name and the last few digits of its number.

  Not every account has one - an Apple Cash balance has nothing to print - and dots with nothing
  after them say less than the name on its own. Mirrors `accountLabel` in the Flutter app.
  """
  def account_label(name, number) when number in [nil, ""], do: name
  def account_label(name, number), do: "#{name} ••••#{number}"
end
