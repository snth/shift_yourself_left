# Dockerfile
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

WORKDIR /transform

# Sync the project into a new environment, using the frozen lockfile
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# Copy the project into the image
COPY dbt_project.yml profiles.yml ./
COPY analyses/ ./analyses/
COPY macros/ ./macros/
COPY models/ ./models/
COPY seeds/ ./seeds/
COPY snapshots/ ./snapshots/
COPY tests/ ./tests/

CMD ["uv", "run", "dbt", "build"]
