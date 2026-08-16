#!/usr/bin/env bash
# Session manager for a QA pass against the running dev app.
#
#   qa.sh start [user]     start the dev server if it is down, launch a scratch Chrome, log in
#   qa.sh run <check.mjs>  run one check script against the live browser session
#   qa.sh log [lines]      tail the dev server log (only if this script started the server)
#   qa.sh stop             kill Chrome, and the server only if this script started it
#
# `start` once, `run` many times: Chrome stays up between checks so the session, the scroll position,
# and the cookies survive, and a check script is a few lines rather than a whole boot sequence.
set -euo pipefail

CMD="${1:?usage: qa.sh start|run|log|stop [...]}"
ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=../../record-demo-video/scripts/worktree_env.sh
. "$SKILL_DIR/../../record-demo-video/scripts/worktree_env.sh"

DEBUG_PORT="${QA_DEBUG_PORT:-$((9322 + WORKTREE_SLOT))}"

# Keyed by slot so a QA session in one worktree does not adopt another's Chrome and screenshots.
STATE="${TMPDIR:-/tmp}/spendable-qa-$WORKTREE_SLOT"
ENV_FILE="$STATE/session.env"
SERVER_LOG="$STATE/server.log"

# Deliberately not `curl -f`: a Phoenix that boots without its database answers every request with a
# 503 error page, and treating that as "down" would start a second server onto a taken port.
server_up() { curl -sS -o /dev/null "http://localhost:$PORT/"; }
root_status() { curl -sS -o /dev/null -w '%{http_code}' "http://localhost:$PORT/"; }

case "$CMD" in
  start)
    DEV_USER="${2:-${DEV_LOGIN_USER:-}}"
    mkdir -p "$STATE"
    : >"$ENV_FILE"

    if server_up; then
      echo "dev server already up on $PORT (left alone; qa.sh stop will not touch it)"
    else
      echo "starting dev server on $PORT, logging to $SERVER_LOG"
      (cd "$ROOT" && nohup mise exec -- mix phx.server >"$SERVER_LOG" 2>&1 &
        echo "QA_SERVER_PID=$!" >>"$ENV_FILE")
      # First boot compiles, so allow well past the usual few seconds before giving up.
      for _ in $(seq 120); do server_up && break; sleep 1; done
      server_up || { echo "server never came up; see $SERVER_LOG" >&2; tail -30 "$SERVER_LOG" >&2; exit 1; }
    fi

    # Port 4000 is a popular default: make sure whatever answered is actually this app before QA'ing
    # someone else's server for twenty minutes.
    if ! curl -sS "http://localhost:$PORT/" | grep -q 'Spendable'; then
      echo "the server on port $PORT is not Spendable." >&2
      echo "another project is squatting the port - stop it, or set PORT." >&2
      exit 1
    fi

    STATUS="$(root_status)"
    case "$STATUS" in
      2*|3*) ;;
      *)
        echo "GET / returns $STATUS - the app is broken before QA starts." >&2
        echo "Diagnose it and tell the dev; do not reset or recreate the dev database." >&2
        exit 1
        ;;
    esac

    CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "$CHROME" --headless=new --remote-debugging-port="$DEBUG_PORT" \
      --user-data-dir="$STATE/chrome-profile" --window-size=1280,860 \
      --hide-scrollbars --force-device-scale-factor=1 \
      --no-first-run --no-default-browser-check about:blank >"$STATE/chrome.log" 2>&1 &
    echo "QA_CHROME_PID=$!" >>"$ENV_FILE"
    for _ in $(seq 20); do
      curl -fs -o /dev/null "http://127.0.0.1:$DEBUG_PORT/json/version" && break
      sleep 0.5
    done

    # A minted session cookie, never a Google password. See session_cookie.exs for why.
    set +e
    COOKIE_OUTPUT="$(cd "$ROOT" && mise exec -- mix run "$SKILL_DIR/../../record-demo-video/scripts/session_cookie.exs" $DEV_USER 2>&1)"
    set -e
    COOKIE_LINE="$(printf '%s\n' "$COOKIE_OUTPUT" | grep SESSION_COOKIE || true)"
    if [ -z "$COOKIE_LINE" ]; then
      echo "could not mint a session cookie; session_cookie.exs said:" >&2
      printf '%s\n' "$COOKIE_OUTPUT" | tail -5 >&2
      exit 1
    fi

    QA_PORT="$PORT" QA_DEBUG_PORT="$DEBUG_PORT" QA_SCRATCH="$STATE/shots" \
      QA_DRIVER="$SKILL_DIR/qa-driver.mjs" \
      QA_COOKIE_NAME="$(echo "$COOKIE_LINE" | awk '{print $2}')" \
      QA_COOKIE_VALUE="$(echo "$COOKIE_LINE" | awk '{print $3}')" \
      node --input-type=module -e '
        const { openQaSession } = await import(process.env.QA_DRIVER)
        const qa = await openQaSession({
          port: Number(process.env.QA_PORT),
          debugPort: Number(process.env.QA_DEBUG_PORT),
          scratchDir: process.env.QA_SCRATCH
        })
        await qa.login({ name: process.env.QA_COOKIE_NAME, value: process.env.QA_COOKIE_VALUE })
        // Structural, not copy: an unauthenticated LiveView mount redirects to "/", so landing
        // anywhere other than /budgets means the cookie was not accepted.
        const path = await qa.evaluate("location.pathname")
        if (path !== "/budgets") throw new Error(`login did not take (landed on ${path})`)
        await qa.finish()
      '

    cat >>"$ENV_FILE" <<EOF
QA_PORT=$PORT
QA_DEBUG_PORT=$DEBUG_PORT
QA_SCRATCH=$STATE/shots
QA_DRIVER=$SKILL_DIR/qa-driver.mjs
QA_USER=$(printf '%s\n' "$COOKIE_OUTPUT" | grep SESSION_USER | awk '{print $2}')
EOF
    echo "logged in; screenshots go to $STATE/shots"
    ;;

  run)
    CHECK="${2:?usage: qa.sh run <check.mjs>}"
    [ -f "$ENV_FILE" ] || { echo "no session: run qa.sh start first" >&2; exit 1; }
    set -a; . "$ENV_FILE"; set +a
    cd "$ROOT"
    node "$CHECK"
    ;;

  log)
    tail -n "${2:-80}" "$SERVER_LOG"
    ;;

  stop)
    [ -f "$ENV_FILE" ] && { set -a; . "$ENV_FILE"; set +a; }
    [ -n "${QA_CHROME_PID:-}" ] && kill "$QA_CHROME_PID" 2>/dev/null || true
    # Only ever stops a server this script started; one the dev was already running is left alone.
    [ -n "${QA_SERVER_PID:-}" ] && kill "$QA_SERVER_PID" 2>/dev/null || true
    rm -f "$ENV_FILE"
    echo "qa session stopped"
    ;;

  *) echo "unknown command $CMD" >&2; exit 1 ;;
esac
