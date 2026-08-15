# Spendable

Privacy focused budgeting.

## Development

Postgres runs in docker compose; everything else runs on the host.

```bash
docker compose up -d db
mix setup
mix phx.server
```

Then visit [`localhost:4000`](http://localhost:4000). Sign-in is Google OAuth, so `.env` needs
`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `PLAID_CLIENT_ID` and `PLAID_SECRET_KEY`.

Gates before anything is done:

```bash
mix format && mix compile --warnings-as-errors && mix credo && mix coveralls
```

## Production

One script installs the whole stack — it prompts for each credential, writes them where the release
expects them, and builds and starts everything.

```bash
scripts/install.sh
```

It brings up postgres, creates and migrates the `spendable` database, and runs the release built from
the `Dockerfile`. Answering yes to the Cloudflare tunnel prompt also runs `cloudflared`, so the app is
published on your hostname without opening a port on the machine — create the tunnel first at
**one.dash.cloudflare.com → Networks → Tunnels**, point its public hostname at `http://app:4000`, and
paste the connector token when asked.

Credentials go to `.secrets/` as one 0600 file per value, because the release reads them as files from
`/etc/secrets` rather than from its environment. `.env.prod` (also 0600) holds the three values docker
compose itself needs. Both are gitignored, and nothing is echoed back or left in shell history.

Re-run the script any time to change a credential; every prompt offers to keep what is already there.
To start it again without the prompts:

```bash
docker compose --env-file .env.prod --profile prod --profile tunnel up -d --build
```

Drop `--profile tunnel` if you are not tunnelling. `PROD_PORT` in `.env.prod` sets the published port,
so a local run can sit alongside a `mix phx.server` already holding 4000.

## Architecture

- [CONTEXT-MAP.md](CONTEXT-MAP.md) - the four contexts and the words each one owns
- [docs/standards.md](docs/standards.md) - code style, contexts, scope, actions, schemas
- [docs/tests.md](docs/tests.md) - what makes a good test, and why there are no factories
