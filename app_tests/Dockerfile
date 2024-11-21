# Dockerfile
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

WORKDIR /app_tests

# Sync the project into a new environment, using the frozen lockfile
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# Activate the environment
ENV PATH="/app_tests/.venv/bin:$PATH"

COPY tests/ ./tests/

CMD ["uv", "run", "pytest", "tests/", "-v"]
