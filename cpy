#!/usr/bin/env bash
# ./cpy — dockerized dev wrapper.
# Reserved verbs route to `docker compose`; anything else runs inside the
# dev container via `docker compose exec`. See `./cpy help` for full usage.
set -euo pipefail

cd "$(dirname "$0")"

usage() {
  cat <<'EOF'
Usage: ./cpy <command> [args...]

Docker lifecycle:
  up                      start services (detached)
  down                    stop services
  build [service]         (re)build images
  logs  [service]         tail logs
  ps                      show running services

Inside the dev container:
  shell                   interactive bash
  <anything else>         run it in the container

Examples:
  ./cpy hello             run the hello CLI (console script)
  ./cpy uv add paho-mqtt  add a dependency
  ./cpy pytest            run tests
  ./cpy python -m foo     arbitrary python
EOF
}

# Echo the command (to stderr, with a `+` prefix a la `set -x`) before running it,
# so users see the underlying docker call without polluting stdout.
run() { printf '+ %s\n' "$*" >&2; "$@"; }

# Start the dev service on demand so `./cpy <cmd>` works without an explicit `./cpy up` first.
ensure_up() {
  if ! docker compose ps --status running --services 2>/dev/null | grep -qx dev; then
    docker compose up -d --wait dev >/dev/null
  fi
}

cmd=${1:-help}
shift || true

case "$cmd" in
  help|-h|--help) usage ;;
  up)             run docker compose up -d "$@" ;;
  down)           run docker compose down   "$@" ;;
  build)          run docker compose build  "$@" ;;
  logs)           run docker compose logs -f "$@" ;;
  ps)             run docker compose ps     "$@" ;;
  shell)          ensure_up; docker compose exec dev bash ;;
  *)              ensure_up; docker compose exec dev "$cmd" "$@" ;;
esac
