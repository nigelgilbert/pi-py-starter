#!/usr/bin/env bash
# Keep /opt/venv aligned with pyproject.toml + uv.lock on every container start.
# A no-op when nothing changed (~100ms); auto-installs when deps drift.
set -euo pipefail

if [[ -f pyproject.toml ]]; then
  uv sync
fi

exec "$@"
