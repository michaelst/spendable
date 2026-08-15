#!/usr/bin/env bash
# Pulls the latest code, rebuilds the release image, and brings the running stack in line with
# docker-compose.yml - migrations included.
#
#   scripts/update.sh
#
# Credentials are left alone; run scripts/install.sh to change those.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
ENV_FILE="$ROOT/.env.prod"

cd "$ROOT"

[ -f "$ENV_FILE" ] || { echo "no .env.prod - run scripts/install.sh first" >&2; exit 1; }

# Uncommitted work would be built into the image without ever being reviewed, so pull only when
# there is nothing local to lose, and say so rather than pulling over it.
if [ -n "$(git status --porcelain)" ]; then
  echo "working tree is dirty - building what is on disk without pulling"
else
  git pull --ff-only
fi

# The tunnel is only part of the stack when install.sh set a token for it.
profiles=(--profile prod)
grep -qE '^TUNNEL_TOKEN=.+' "$ENV_FILE" && profiles+=(--profile tunnel)

# --remove-orphans is what makes this "match the compose file": a service deleted from
# docker-compose.yml keeps running forever otherwise.
docker compose --env-file "$ENV_FILE" "${profiles[@]}" up -d --build --remove-orphans

echo
docker compose --env-file "$ENV_FILE" "${profiles[@]}" ps
echo
echo "Old image layers are still on disk; reclaim them with: docker image prune -f"
