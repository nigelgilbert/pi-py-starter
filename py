#!/usr/bin/env bash
# ./py — dockerized dev wrapper.
# Reserved verbs route to `docker compose`; anything else runs inside the
# dev container via `docker compose exec`. See `./py help` for full usage.
set -euo pipefail

cd "$(dirname "$0")"

usage() {
  cat <<'EOF'
Usage: ./py <command> [args...]

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
  ./py hello             run the hello CLI (console script)
  ./py uv add paho-mqtt  add a dependency
  ./py pytest            run tests
  ./py python -m foo     arbitrary python
EOF
}

# Echo the command (to stderr, with a `+` prefix a la `set -x`) before running it,
# so users see the underlying docker call without polluting stdout.
run() { printf '+ %s\n' "$*" >&2; "$@"; }

# Start the dev service on demand so `./py <cmd>` works without an explicit `./py up` first.
# Gates on container *health* (uv sync --check), not merely "running".
ensure_up() {
  if [[ "$(docker compose ps dev --format '{{.Health}}' 2>/dev/null)" != "healthy" ]]; then
    docker compose up -d --wait dev >/dev/null
  fi
}

cmd=${1:-help}
shift || true

case "$cmd" in
  help|-h|--help) usage ;;
  up)             run docker compose up -d --wait "$@" ;;
  down)           run docker compose down   "$@" ;;
  build)          run docker compose build  "$@" ;;
  logs)           run docker compose logs -f "$@" ;;
  ps)             run docker compose ps     "$@" ;;
  shell)          ensure_up; docker compose exec dev bash ;;
  *)              ensure_up; docker compose exec dev "$cmd" "$@" ;;
esac
