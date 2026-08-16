#!/usr/bin/env bash
# Records a scenario against the running dev app and encodes it to mp4.
#
#   .claude/skills/record-demo-video/scripts/record.sh <scenario.mjs> <output.mp4> [user]
#
# Launches its own headless Chrome (never the user's profile), mints a signed session cookie, runs
# the scenario, encodes the frames, then cleans up. Needs the dev server already running.
set -euo pipefail

SCENARIO="${1:?usage: record.sh <scenario.mjs> <output.mp4> [user]}"
OUTPUT="${2:?usage: record.sh <scenario.mjs> <output.mp4> [user]}"

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Users have no email - identify by UXID or Google external_id, or take the oldest one.
DEV_USER="${3:-${DEV_LOGIN_USER:-}}"

# shellcheck source=worktree_env.sh
. "$SKILL_DIR/worktree_env.sh"

DEBUG_PORT="${DEMO_DEBUG_PORT:-$((9222 + WORKTREE_SLOT))}"
FPS="${DEMO_FPS:-8}"
FRAME_DIR="${DEMO_FRAME_DIR:-${TMPDIR:-/tmp}/demo-frames-$$}"

if ! curl -fsS -o /dev/null "http://localhost:$PORT/"; then
  echo "no dev server on port $PORT: start it first (mix phx.server)" >&2
  exit 1
fi

# Port 4000 is a popular default, and a worktree's app is not on it: make sure whatever answered is
# this checkout's app before recording a video of someone else's.
if ! curl -sS "http://localhost:$PORT/" | grep -q 'Spendable'; then
  echo "the server on port $PORT is not Spendable - stop whatever is squatting the port, or set PORT." >&2
  exit 1
fi

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PROFILE="${TMPDIR:-/tmp}/demo-chrome-profile-$DEBUG_PORT"

"$CHROME" --headless=new --remote-debugging-port="$DEBUG_PORT" \
  --user-data-dir="$PROFILE" --window-size=1280,860 \
  --hide-scrollbars --force-device-scale-factor=1 \
  --no-first-run --no-default-browser-check about:blank >"${TMPDIR:-/tmp}/demo-chrome-$DEBUG_PORT.log" 2>&1 &
CHROME_PID=$!
trap 'kill "$CHROME_PID" 2>/dev/null || true' EXIT

# Quiet on purpose: the first attempts fail while Chrome boots, which is not worth reporting.
for _ in $(seq 20); do
  curl -fs -o /dev/null "http://127.0.0.1:$DEBUG_PORT/json/version" && break
  sleep 0.5
done

cd "$ROOT"
# `set -e` plus `pipefail` would kill the script on grep's no-match exit before the message below
# ever printed, so the whole run failed with no output at all. Capture first, then report.
set +e
COOKIE_OUTPUT="$(mise exec -- mix run "$SKILL_DIR/session_cookie.exs" $DEV_USER 2>&1)"
set -e
COOKIE_LINE="$(printf '%s\n' "$COOKIE_OUTPUT" | grep SESSION_COOKIE || true)"
if [ -z "$COOKIE_LINE" ]; then
  echo "could not mint a session cookie" >&2
  echo "  pass a user id or external_id as the third argument, or set DEV_LOGIN_USER." >&2
  echo "  session_cookie.exs said:" >&2
  printf '%s\n' "$COOKIE_OUTPUT" | tail -5 >&2
  exit 1
fi

DEMO_FRAME_DIR="$FRAME_DIR" DEMO_PORT="$PORT" DEMO_DEBUG_PORT="$DEBUG_PORT" \
  DEMO_COOKIE_NAME="$(echo "$COOKIE_LINE" | awk '{print $2}')" \
  DEMO_COOKIE_VALUE="$(echo "$COOKIE_LINE" | awk '{print $3}')" \
  DEMO_DRIVER="$SKILL_DIR/driver.mjs" node "$SCENARIO"

swift "$SKILL_DIR/encode.swift" "$FRAME_DIR" "$OUTPUT" "$FPS"
echo "FRAMES_KEPT $FRAME_DIR"
