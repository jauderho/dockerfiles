# Guidelines for Containerizing a New Program

This document provides instructions on how to add a new program to this repository. Following these guidelines ensures consistency, security, and maintainability across all Docker images.

## 1. Directory Structure

For a new program named `<program>`:
- Create a directory named `<program>` in the root of the repository.
- Place the `Dockerfile` and a basic `README.md` inside the `<program>` directory.
- Create a GitHub Action workflow file at `.github/workflows/<program>.yml`.

## 2. GitHub Action Workflow Requirements (`.github/workflows/<program>.yml`)

- **Security**:
    - Use [Step Security's `harden-runner`](https://github.com/step-security/harden-runner) in all workflows.
    - Pin all GitHub Actions to **full commit hashes**. Include a comment with the corresponding semantic version for readability.
      Example: `uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v4.2.2`
- **Configuration**:
    - Hardcode the `BUILD_VERSION` in the `env` section of the workflow.
    - Ensure the workflow pushes the built image to both **GitHub Container Registry (ghcr.io)** and **Docker Hub**.
- **Triggers**:
    - Include triggers for `push` (filtered by paths), `workflow_dispatch`, and a weekly `schedule`.

See `.github/workflows/adguardhome.yml` for a modern example.

## 3. Dockerfile Standards

- **Base Images**:
    - **Always** use image digests (e.g., `image@sha256:...`) for base images to ensure build reproducibility and security.
    - For **Go** applications, use `ghcr.io/jauderho/golang` as the build base.
    - For **Alpine-based** final images, use `ghcr.io/jauderho/alpine`.
- **Optimization**:
    - Aim for multi-stage builds to keep the final image size minimal.
    - Hardening: Whenever possible, run the application as a non-root user.

## 4. Program README (`<program>/README.md`)

Each program directory must contain a `README.md` with standard badges and usage information. Use the following badge pattern (replace `<program>` with the actual name):

```markdown
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/<program>/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/<program>/latest)](https://github.com/<upstream_author>/<upstream_repo>/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/<program>)](https://hub.docker.com/r/jauderho/<program>/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/<program>/latest)](https://hub.docker.com/r/jauderho/<program>/)
```

## 5. Root Repository Updates

When adding a new program, you MUST update the following files in the root directory:
- **`README.md`**: Add the new program to the "Build Status" table.
- **`BUILD_STATUS.md`**: Add the new program to the table.

**Important**: Entries in both files must be kept in **alphabetical order**.

## 6. Language-Specific Examples

Use the following existing programs as templates for new additions:
- **Go**: `adguardhome`
- **Rust**: `onetun`
- **Python**: `ruff` or `ansible`

Avoid using the `templates/` directory as it may contain outdated patterns.
