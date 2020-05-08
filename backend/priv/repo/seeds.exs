middleware = [
  {Tesla.Middleware.BaseUrl, Application.get_env(:spendable, Plaid)[:base_url]},
  Tesla.Middleware.JSON
]

{:ok, %{body: %{"categories" => categories}}} =
  Tesla.client(middleware, {Tesla.Adapter.Mint, []})
  |> Tesla.post("/categories/get", %{})

Spendable.Banks.Category.Utils.import_categories(categories)
