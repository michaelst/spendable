# Spendable API

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Deploy

```bash
helm upgrade --install spendable-api ../server-config/helm-app \
  -f backend/.devops/helm/values.yaml \
  --set image.repository=ghcr.io/michaelst/spendable-api \
  --set image.tag=${COMMIT_SHA} \
  --atomic \
  --debug \
  -n backend
```