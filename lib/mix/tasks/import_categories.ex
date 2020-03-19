defmodule Mix.Tasks.Import.Categories do
  use Mix.Task

  alias Spendable.Banks.Category.Utils

  @shortdoc "Import categories from Plaid."
  def run(_opts) do
    Mix.Task.run("app.start")

    Utils.get_categories()
    |> Utils.import_categories()
  end
end
