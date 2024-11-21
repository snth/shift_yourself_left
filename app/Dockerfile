# Dockerfile
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

WORKDIR /app

# Sync the project into a new environment, using the frozen lockfile
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# Activate the environment
ENV PATH="/app/.venv/bin:$PATH"

# Copy the project into the image
COPY recipes/ ./recipes/

CMD ["uv", "run", "uvicorn", "recipes.main:app", "--host", "0.0.0.0", "--port", "8000"]
