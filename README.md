# pi-cpy-starter

CPython on a Raspberry Pi. Dockerized dev on the Mac, native source deploy
on the Pi. Fork it for MQTT / GPIO / hardware-poking projects.

## Philosophy

**The Mac stays clean. The Pi runs without a container.**

- **Mac:** zero Python on the host. Everything happens inside Docker, via `./cpy`.
- **Pi:** Python 3.11, `uv`, git, and systemd installed directly.
- **Reproducibility:** [`uv.lock`](uv.lock) is the contract. The Pi installs
  the same resolved deps the dev container did.

Requires OrbStack or Docker Desktop on the Mac. That is the whole host-side toolchain.

## Dev loop

Everything routes through [`./cpy`](cpy):

```
./cpy hello                 # run the CLI
./cpy shell                 # bash in the container
./cpy uv add paho-mqtt      # add a dep (writes pyproject.toml + uv.lock)
./cpy pytest                # tests
./cpy up / down / logs      # docker compose verbs
./cpy help                  # all verbs
```

Source is bind-mounted, so VS Code edits take effect instantly. The venv lives
in a named Docker volume and never touches your filesystem. `uv.lock` is
written back to the repo, so commit it like normal.

**VS Code:** open the folder, "Reopen in Container". Pylance, Ruff, and the
debugger all work in-container via
[`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json).

## Deploy

> SSH in. `git pull`. `uv sync`. `systemctl restart`. Done.

No Docker on the Pi. No registry. No image pushes. The Pi clones the same
repo and runs the source natively against `uv.lock`.

### First-time Pi setup

```bash
ssh pi@raspberrypi.local

# System deps. build-essential + python3-dev are for building CPython C extensions.
sudo apt update
sudo apt install -y python3 python3-venv python3-dev build-essential git gettext-base

# uv (static arm64 binary, ~10MB)
curl -LsSf https://astral.sh/uv/install.sh | sh && source ~/.bashrc

# Clone + install. pyproject.toml pins Python ==3.11.*, same minor as the
# dev container, so C extensions built there also load here.
git clone https://github.com/YOU/pi-cpy-starter.git ~/app
cd ~/app && uv sync --frozen --no-dev

# Install the systemd unit (substitutes $USER / $HOME into the template).
envsubst < deploy/hello.service | sudo tee /etc/systemd/system/hello.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable --now hello
```

### Every deploy after that

```bash
ssh pi@raspberrypi.local
cd ~/app && git pull && uv sync --frozen --no-dev
sudo systemctl restart hello
journalctl -fu hello
```

Three commands after SSH. No images, no registries, no daemons.

## Layout

```
.
├── cpy                    # bash wrapper for the container
├── Dockerfile             # dev-only image (CPython 3.11 + uv + non-root user)
├── compose.yaml           # dev service; extend for a local MQTT broker
├── pyproject.toml         # project + deps (managed by uv)
├── uv.lock                # pinned deps, shared with the Pi
├── src/hello/             # package code
├── .docker/entrypoint.sh  # auto `uv sync` + readiness marker
├── .devcontainer/         # VS Code attach config
└── deploy/hello.service   # systemd unit template for the Pi
```

## Forking checklist

When this becomes your real project:

1. Rename `src/hello/` → `src/yourapp/`
2. Update `[project].name` + `[project.scripts]` in `pyproject.toml`
3. Rename `deploy/hello.service`; update its `ExecStart` and `Description`
4. Uncomment the `mqtt` service in `compose.yaml` for a local Mosquitto broker
5. `./cpy uv add paho-mqtt` (or your client of choice)
