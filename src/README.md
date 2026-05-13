# src/

Adding a new `./cpy <name>` script:

1. Create `hello/<name>.py` with `def main() -> None:`
2. Add `<name> = "hello.<name>:main"` to `[project.scripts]` in `../pyproject.toml`
3. `./cpy uv sync` to install the wrapper into `/opt/venv/bin/`

Then `./cpy <name>` runs it inside the container.
