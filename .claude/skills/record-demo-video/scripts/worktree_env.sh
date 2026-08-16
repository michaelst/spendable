# Where this checkout's dev app lives. Source it, do not run it.
#
# A worktree runs its own app on its own port (scripts/setup-worktree.sh writes them to
# .env.worktree), so a QA or demo pass that assumes 4000 drives whatever else is on 4000 - the main
# checkout, or another worktree's app - and reports on the wrong code. Everything keyed off the slot
# so two worktrees can record at the same time without fighting over a debug port or a state dir.
#
# Sets: PORT, WORKTREE_SLOT. Expects ROOT to be the repo root.
#
# An explicit PORT in the environment always wins.

WORKTREE_ENV="$ROOT/.env.worktree"

read_worktree_var() {
  [ -f "$WORKTREE_ENV" ] || return 0
  grep -E "^$1=" "$WORKTREE_ENV" 2>/dev/null | head -1 | cut -d= -f2
}

WORKTREE_SLOT="$(read_worktree_var WORKTREE_SLOT)"
WORKTREE_SLOT="${WORKTREE_SLOT:-0}"

if [ -z "${PORT:-}" ]; then
  PORT="$(read_worktree_var PORT)"
  PORT="${PORT:-4000}"
fi

if [ "$WORKTREE_SLOT" != "0" ]; then
  echo "worktree slot $WORKTREE_SLOT: driving the app on port $PORT" >&2
fi
