# syntax=docker/dockerfile:1.7
#
# Dev-only image. The entire point is to keep the Mac workstation clean —
# all Python toolchain lives in here. The Pi runs source natively; it does
# NOT use this image. See README.md ("Deploy") for the Pi side.

FROM python:3.13-slim-trixie

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH=/opt/venv/bin:/usr/local/bin:$PATH

# build-essential: needed for compiling CPython C extensions from source
# (the whole point of this starter). Python headers ship with the base image.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates git build-essential \
 && rm -rf /var/lib/apt/lists/*

# Tiny static uv binary pulled from its official image.
# Pinned for reproducibility — bump intentionally. Kept below the apt layer
# so a uv bump doesn't invalidate the apt cache.
COPY --from=ghcr.io/astral-sh/uv:0.11.14 /uv /uvx /usr/local/bin/

# uid/gid 1000 hardcoded: matches the first user on most Linux distros, and
# Mac file ownership is mapped by the VM anyway. Forking on Linux with a
# different uid? Change the numbers here.
RUN groupadd --gid 1000 dev \
 && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash dev \
 && mkdir -p /workspace /opt/venv /home/dev/.cache/uv \
 && chown -R dev:dev /workspace /opt/venv /home/dev/.cache

WORKDIR /workspace

COPY --chmod=755 .docker/entrypoint.sh /usr/local/bin/entrypoint.sh

USER dev
ENTRYPOINT ["entrypoint.sh"]
CMD ["sleep", "infinity"]
