#!/usr/bin/env bash
# Interactive install for the production stack. Prompts for every credential, writes them where the
# release expects them, and brings the stack up.
#
#   scripts/install.sh
#
# Secrets land in .secrets/ as one 0600 file per credential, because the release reads them as files
# from /etc/secrets rather than from its environment - a value in a file cannot leak through `ps`,
# `docker inspect`, or a crash dump the way an environment variable can. Nothing is echoed back and
# nothing is written to shell history.
#
# Re-run it any time: every prompt offers to keep what is already there.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SECRETS="$ROOT/.secrets"
ENV_FILE="$ROOT/.env.prod"

command -v docker >/dev/null || { echo "docker is required" >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "docker compose v2 is required" >&2; exit 1; }

# 0700 so the files are unreadable to anyone else on the machine, even before they exist.
mkdir -p "$SECRETS"
chmod 700 "$SECRETS"

# Written with printf '%s' rather than echo: the release reads each file verbatim, so a trailing
# newline would become part of the password.
write_secret() {
  printf '%s' "$2" >"$SECRETS/$1"
  chmod 600 "$SECRETS/$1"
}

# $1 name, $2 prompt, $3 "hidden" to suppress echo, $4 default for a first install
ask_secret() {
  local name="$1" label="$2" hidden="${3:-}" default="${4:-}" current="" suffix="" value=""

  [ -f "$SECRETS/$name" ] && current="$(cat "$SECRETS/$name")"

  if [ -n "$current" ]; then
    suffix=" [keep existing]"
  elif [ -n "$default" ]; then
    suffix=" [$default]"
  fi

  if [ "$hidden" = "hidden" ]; then
    read -rsp "$label$suffix: " value
    echo
  else
    read -rp "$label$suffix: " value
  fi

  value="${value:-${current:-$default}}"
  [ -n "$value" ] || { echo "$name cannot be empty" >&2; exit 1; }
  write_secret "$name" "$value"
}

echo "Spendable production install"
echo

read -rp "Public hostname [${PHX_HOST:-localhost}]: " hostname
hostname="${hostname:-${PHX_HOST:-localhost}}"

echo
echo "Google OAuth (console.cloud.google.com)"
ask_secret GOOGLE_CLIENT_ID "  Client ID"
ask_secret GOOGLE_CLIENT_SECRET "  Client secret" hidden

echo
echo "Plaid (dashboard.plaid.com)"
ask_secret PLAID_CLIENT_ID "  Client ID"
ask_secret PLAID_SECRET_KEY "  Secret key" hidden

echo
echo "Database"
ask_secret DB_PASSWORD "  Postgres password" hidden postgres

# Rotating this on every run would invalidate every signed session, so it is generated once and kept.
if [ -s "$SECRETS/SECRET_KEY_BASE" ]; then
  echo
  echo "Keeping the existing SECRET_KEY_BASE."
else
  write_secret SECRET_KEY_BASE "$(openssl rand -base64 64 | tr -d '\n=')"
  echo
  echo "Generated a SECRET_KEY_BASE."
fi

echo
read -rp "Serve through a Cloudflare tunnel? [y/N]: " use_tunnel
tunnel_token=""

if [[ "$use_tunnel" =~ ^[Yy] ]]; then
  [ "$hostname" = "localhost" ] &&
    echo "  note: a tunnel needs a real hostname - rerun and set one if this was not deliberate."
  echo "  Create the tunnel at one.dash.cloudflare.com > Networks > Tunnels, point its public"
  echo "  hostname $hostname at http://app:4000, then paste the connector token."
  ask_secret CLOUDFLARE_TUNNEL_TOKEN "  Tunnel token" hidden
  tunnel_token="$(cat "$SECRETS/CLOUDFLARE_TUNNEL_TOKEN")"
fi

# Compose needs three of these for its own variable substitution, so they are duplicated out of
# .secrets into a file only this user can read. The rest never leave .secrets.
{
  echo "PHX_HOST=$hostname"
  echo "POSTGRES_PASSWORD=$(cat "$SECRETS/DB_PASSWORD")"
  echo "TUNNEL_TOKEN=$tunnel_token"
  # Behind a tunnel nothing needs to reach the app from outside this machine, so bind loopback only.
  if [ -n "$tunnel_token" ]; then
    echo "PROD_PORT=127.0.0.1:4000"
  else
    echo "PROD_PORT=4000"
  fi
} >"$ENV_FILE"
chmod 600 "$ENV_FILE"

profiles=(--profile prod)
[ -n "$tunnel_token" ] && profiles+=(--profile tunnel)

echo
echo "Wrote $SECRETS (0600) and $ENV_FILE (0600). Both are gitignored."
read -rp "Build and start the stack now? [Y/n]: " start
if [[ ! "$start" =~ ^[Nn] ]]; then
  cd "$ROOT"
  docker compose --env-file "$ENV_FILE" "${profiles[@]}" up -d --build
  echo
  if [ -n "$tunnel_token" ]; then
    echo "Running at https://$hostname through the tunnel."
  else
    echo "Running at http://localhost:4000."
  fi
else
  echo
  echo "Start it later with:"
  echo "  docker compose --env-file .env.prod ${profiles[*]} up -d --build"
fi
