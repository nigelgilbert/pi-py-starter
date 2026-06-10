# deploy/

Pi-side assets. Nothing here is used by the dev container — these files live
and run on the Raspberry Pi itself.

## Contents

- [`hello.service`](hello.service) — systemd unit template that supervises
  the app: auto-starts on boot, restarts on failure, waits for the network.
  `${USER}` / `${HOME}` placeholders are substituted at install time via
  `envsubst '$USER $HOME'` so it works regardless of which username you chose
  on first boot (only allowlisted variables are substituted; anything else,
  like systemd's `$MAINPID`, passes through verbatim). Points at
  `$HOME/app/.venv/bin/hello`, the console script installed from
  [`pyproject.toml`](../pyproject.toml).

## Install

The canonical install and deploy commands live in the root README:

- One-time install: [First-time Pi setup](../README.md#first-time-pi-setup)
- Routine deploys: [Every deploy after that](../README.md#every-deploy-after-that)

Routine deploys never touch anything in here. The unit is boring, long-lived
infrastructure.

To install under a different user or path, prefix the env vars:

```bash
USER=appuser HOME=/opt/appuser envsubst '$USER $HOME' < deploy/hello.service | sudo tee ...
```

## On fork

1. Rename `hello.service` to match your app (e.g. `pi-mqtt.service`)
2. Update `Description` and `ExecStart` inside
3. Reinstall on the Pi: `sudo systemctl disable --now hello` then repeat the
   [install steps](../README.md#first-time-pi-setup) with the new name

## Likely future residents

When this boilerplate grows into the real MQTT project, expect to add:

- `mosquitto.conf` — broker config, if Mosquitto runs on the Pi
- `99-aioc.rules` — udev rule so `pi` can access `/dev/ttyACM0` (the NA6 AIOC cable) without sudo
- `bootstrap.sh` — one-shot script wrapping the README's apt/uv/systemd dance
