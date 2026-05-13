# pi-cpy-starter

Raspberry Pi **CPython** boilerplate (not MicroPython / CircuitPython).
Dockerized dev on the Mac, native source deploy on the Pi. Fork this for
MQTT / GPIO / hardware-poking projects.

## Philosophy

**Dev environment stays clean. Pi cleanliness doesn't matter as much.**

- On the Mac: zero Python toolchain on the host. Everything lives inside a Docker container.
  Edit scripts in VS Code, run them via `./cpy hello`.
- On the Pi: install Python, `uv`, and git directly. It's the target box; it's
  supposed to have the runtime. No Docker daemon, no images, no cross-compiles.
- Reproducibility comes from `uv.lock`: the Pi installs byte-identical deps to
  your dev container.

## Requirements

- **Mac (workstation):** Docker Desktop. That is the entire host-side toolchain.
- **Pi (target):** Python 3.11 (system Python on Pi OS Bookworm), git, `uv`, systemd. One-time setup below.

## Dev loop (on your Mac)

Everything goes through `./cpy`:

```
./cpy hello                 # run the CLI
./cpy shell                 # interactive bash inside the container
./cpy uv add paho-mqtt      # add a dependency (writes pyproject.toml + uv.lock)
./cpy pytest                # run tests
./cpy python -m foo         # arbitrary python
./cpy up / down / logs      # reserved verbs route to docker compose
./cpy help                  # all verbs
```

Source is bind-mounted, so edits on the Mac take effect immediately inside the
container. The venv lives in a named Docker volume, so it never pollutes your
filesystem. `uv.lock` is written back to the repo (bind mount), so you commit
it like normal.

**VS Code:** open the folder, click "Reopen in Container". Pylance, Ruff, and
the debugger all work in-container via
[`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json).

## Deployment

> **You SSH into the Pi, `git pull`, `uv sync`, `systemctl restart`. That's it.**

No Docker on the Pi. No registry. No image pushes. The Pi just clones the same
repo and runs the source natively with the deps from `uv.lock`.

### One-time Pi setup

SSH in once and bootstrap:

```bash
ssh pi@raspberrypi.local

# System deps. build-essential + python3-dev are required for building
# CPython C extensions on the Pi (this starter targets CPython-level work).
sudo apt update
sudo apt install -y python3 python3-venv python3-dev build-essential git gettext-base

# uv (static arm64 binary, ~10MB)
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc

# Clone the repo and install deps from the lockfile.
# `pyproject.toml` pins `requires-python = "==3.11.*"` to match Pi OS Bookworm's
# system Python — so `uv sync` uses /usr/bin/python3 directly. Keeping the ABI
# aligned with the dev container's 3.11 means compiled C extensions built in
# the container also load on the Pi.
git clone https://github.com/YOU/pi-cpy-starter.git ~/app
cd ~/app
uv sync --frozen --no-dev

# Install the systemd unit (substitutes $USER / $HOME into the template)
# USER=appuser
# HOME=/opt/appuser
envsubst < deploy/hello.service | sudo tee /etc/systemd/system/hello.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable --now hello
```

### Every deploy thereafter

```bash
ssh pi@raspberrypi.local
cd ~/app
git pull
uv sync --frozen --no-dev
sudo systemctl restart hello
journalctl -fu hello           # watch it come back up
```

Three commands after SSH. No images, no registries, no daemons.

## Project layout

```
.
├── Dockerfile              # dev-only image (CPython + uv + non-root user)
├── compose.yaml            # dev service; extend here for a local MQTT broker
├── cpy                     # bash wrapper — your CLI into the container
├── pyproject.toml          # project + deps (managed by uv)
├── uv.lock                 # pinned deps — source of truth for Pi too
├── src/hello/              # package code
├── .docker/entrypoint.sh   # auto `uv sync` + readiness marker
├── .devcontainer/          # VS Code attach config
├── deploy/hello.service    # systemd unit template for the Pi
└── docs/                   # design notes, hardware info, scratch
```

## What's not here (yet) and why

- **No `runtime` Docker stage.** Native Pi deploy doesn't use a container image.
- **No MQTT broker in `compose.yaml`.** The boilerplate is intentionally bare.
  A commented-out Mosquitto scaffold is in [`compose.yaml`](compose.yaml) for when
  you fork this.
- **No tests.** Add `pytest` with `./cpy uv add --dev pytest` when you need them.

## Forking checklist

When you fork this for the real MQTT project:

1. Rename the package: `src/hello/` → `src/yourapp/`
2. Update `[project]` name + `[project.scripts]` in `pyproject.toml`
3. Rename `deploy/hello.service` and update `ExecStart` + `Description`
4. Uncomment the `mqtt` service in `compose.yaml` (Mosquitto for local testing)
5. `./cpy uv add paho-mqtt` to add the MQTT client library
