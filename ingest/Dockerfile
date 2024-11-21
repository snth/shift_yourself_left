# Dockerfile
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

WORKDIR /ingest

# Sync the project into a new environment, using the frozen lockfile
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

COPY ingest.py .

CMD ["uv", "run", "python", "ingest.py"]
