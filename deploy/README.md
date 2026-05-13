# deploy/

Pi-side assets. Nothing here is used by the dev container — these files live
and run on the Raspberry Pi itself.

## Contents

- [`hello.service`](hello.service) — systemd unit template that supervises
  the app: auto-starts on boot, restarts on failure, waits for the network.
  `${USER}` / `${HOME}` placeholders are substituted at install time via
  `envsubst` so it works regardless of which username you chose on first
  boot. Points at `$HOME/app/.venv/bin/hello`, the console script `uv sync`
  installs from [`pyproject.toml`](../pyproject.toml).

## Install (one-time, on the Pi)

```bash
envsubst < deploy/hello.service | sudo tee /etc/systemd/system/hello.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable --now hello
journalctl -fu hello          # tail logs
```

To install under a different user or path, prefix the env vars:

```bash
USER=appuser HOME=/opt/appuser envsubst < deploy/hello.service | sudo tee ...
```

After this, the "every deploy" flow from the [root README](../README.md#every-deploy-thereafter)
never touches anything in here — `git pull && uv sync && systemctl restart hello`
and you're done. The unit is boring, long-lived infrastructure.

## On fork

1. Rename `hello.service` to match your app (e.g. `pi-mqtt.service`)
2. Update `Description` and `ExecStart` inside
3. Reinstall on the Pi: `sudo systemctl disable --now hello` then repeat the install steps with the new name

## Likely future residents

When this boilerplate grows into the real MQTT project, expect to add:

- `mosquitto.conf` — broker config, if Mosquitto runs on the Pi
- `99-aioc.rules` — udev rule so `pi` can access `/dev/ttyACM0` (the NA6 AIOC cable) without sudo
- `bootstrap.sh` — one-shot script wrapping the README's apt/uv/systemd dance
