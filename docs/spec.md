# Memo: Recommended CPython Development Environment for Raspberry Pi IoT Work

**Date:** April 19, 2026  
**Subject:** CPython development setup on macOS for Raspberry Pi MQTT/IoT projects

## Purpose

This memo outlines a practical and security-conscious way to develop a CPython-based IoT application on a clean MacBook Pro while targeting a Raspberry Pi Linux box using MQTT.

## Recommendation

Develop **CPython inside a Linux container on the Mac**, but do **not** treat Docker as a replacement for Python virtual environments.

Use both:

- **Docker** for OS/runtime isolation, reproducibility, and keeping the Mac clean
- **`venv`** or a similar Python dependency workflow inside the container for package isolation

In other words:

> Use containers for the system boundary, and Python environments for the package boundary.

## Why This Fits the Goal

The stated goals are:

- develop on a clean macOS machine
- avoid “dirtying up” the host with language runtimes and toolchains
- reduce attack surface in a home lab setting
- target Raspberry Pi Linux for MQTT-based IoT workloads
- stay close to **CPython**

This setup fits well because the Mac host only needs a small set of tools, while the actual Python runtime and dependencies live in a disposable Linux environment.

## Core Approach

### 1. Keep the Mac Minimal

Install only the essentials on the Mac host:

- Docker Desktop or an equivalent container runtime
- an editor such as VS Code, Cursor, or Neovim
- optional SSH tooling

Avoid installing a full local Python toolchain unless there is a specific host-side need.

This keeps the laptop cleaner and reduces the amount of host-level software that could expand the attack surface.

### 2. Use an Official Python-Based Linux Container

For a CPython-centered workflow, use a Linux container based on an official Python image.

That gives you:

- a predictable Linux runtime
- CPython inside the container
- alignment with the Linux target environment
- fewer “works on macOS but not on Pi” surprises

### 3. Still Use a Python Environment Inside the Container

Even inside Docker, it is still useful to use:

- `.venv`
- `pip`
- or `uv` for dependency and environment management

Docker isolates the OS/runtime layer.  
A Python environment isolates Python packages within that runtime.

These are complementary, not competing, tools.

## Practical Setup

A good repo layout is:

- `pyproject.toml`
- `Dockerfile`
- `compose.yaml`
- `.devcontainer/devcontainer.json`

### Suggested workflow

1. Build a Linux dev container with CPython
2. Mount only the project directory into the container
3. Create and use a `.venv` inside the container for development
4. Use Docker Compose to run:
   - the app container
   - a local MQTT broker for testing
5. Build deployment images separately for the Raspberry Pi target

## MQTT / IoT Notes

For Raspberry Pi IoT development using MQTT, the normal Python choice is:

- **Eclipse Paho MQTT client**

That is the standard, boring, reliable option for Python MQTT work and is usually the right default unless you have a strong reason to do otherwise.

## Security Perspective

Containerization helps, but it is not magic. The real security benefits in a home lab come from **reducing what lives on the host** and **keeping boundaries tight**.

### Security advantages of this approach

- fewer runtimes installed directly on macOS
- fewer host-level package managers and language toolchains
- disposable development environments
- easier rebuilds after mistakes or compromise
- smaller chance of polluting the host with dev dependencies

### What actually matters most

To keep the setup safer:

- mount only the repo, not the whole home directory
- avoid privileged containers
- do not run containers as root unless necessary
- keep images small and focused
- separate dev and deployment images
- do not store secrets directly in source
- patch base images regularly

### Important nuance

Containers improve isolation, but bind mounts still expose host files to the container.  
So the biggest win is not “Docker = secure,” but rather:

> “Docker lets me limit what the development environment can touch.”

## Raspberry Pi Deployment Guidance

### Best case

This setup is smoothest when the target is:

- Raspberry Pi 3, 4, or 5
- 64-bit Raspberry Pi OS
- preferably `linux/arm64`

That path lines up well with modern container tooling and multi-arch image builds.

### More caution required

Be more careful if targeting:

- 32-bit Raspberry Pi OS
- very old boards
- ARMv6 devices such as Pi Zero / Zero W / Pi 1

In those cases, container support is less convenient, and a simpler non-container deployment may be easier.

## Recommended Decision

### Development on the Mac

**Yes — containerize it.**

This is the cleanest way to:

- keep the Mac uncluttered
- stay Linux-like during development
- reduce host exposure
- maintain reproducibility

### Python environment strategy

**No — do not abandon Python’s env system.**

Use:

- Docker for system isolation
- `venv`/`pip`/`uv` for Python dependency isolation

### Final stance

The best answer is:

> Dockerize the development environment, but still use Python environment discipline inside the container.

## Suggested Baseline Policy

For this project, the default policy should be:

- **Host:** minimal tools only
- **Dev runtime:** Linux container with CPython
- **Python deps:** managed in-container with `.venv`
- **Messaging:** local MQTT broker in Compose
- **Target builds:** multi-arch images for Raspberry Pi when appropriate
- **Security posture:** least privilege, minimal mounts, minimal host tooling

## Bottom Line

For a clean MacBook Pro and a Raspberry Pi MQTT/IoT target, the best setup is a **Linux-based CPython dev container** with **normal Python dependency isolation inside it**.

That gives you:

- a cleaner host
- better reproducibility
- a closer match to the Raspberry Pi target
- lower host-level exposure in a home lab

It is the most practical “secure enough and maintainable” approach for this use case.