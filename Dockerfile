# syntax=docker/dockerfile:1.7
#
# Dev-only image. The entire point is to keep the Mac workstation clean —
# all Python toolchain lives in here. The Pi runs source natively; it does
# NOT use this image. See README.md ("Deploy") for the Pi side.

FROM python:3.13-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH=/opt/venv/bin:/usr/local/bin:$PATH

# Tiny static uv binary pulled from its official image.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates git \
 && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000
RUN groupadd --gid ${GID} dev \
 && useradd --uid ${UID} --gid ${GID} --create-home --shell /bin/bash dev \
 && mkdir -p /workspace /opt/venv /home/dev/.cache/uv \
 && chown -R dev:dev /workspace /opt/venv /home/dev/.cache

WORKDIR /workspace

COPY --chmod=755 .docker/entrypoint.sh /usr/local/bin/entrypoint.sh

USER dev
ENTRYPOINT ["entrypoint.sh"]
CMD ["sleep", "infinity"]
