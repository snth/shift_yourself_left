# Shift Yourself Left: Integration Testing for Data Engineers

This repository contains the code for the Shift Yourself Left: Integration Testing for Data Engineers project.
It is intended to be the simplest possible example of how to integrate a containerized data pipeline built
using [DuckDB](https://duckdb.org/), [dbt-duckdb](https://github.com/duckdb/dbt-duckdb), and [dlt](https://dlthub.com/)
with an upstream web service built using [FastAPI](https://fastapi.tiangolo.com/) and MySQL such that the
application and its data pipeline can be containerized, deployed, and tested as part of a CI/CD system. This
enables the data pipeline to be created and tested in a way that is fully integrated with its upstream
web service and allows us to test as much of the pipeline as possible in a real-world environment *before* the
integration is deployed to production.

The project is split into five parts:

1. The FastAPI web service, which provides a simple API for managing recipes. This is defined in the `app` directory.
1. The app tests, which are defined in the `app_tests` directory and contains a [pytest](https://docs.pytest.org/) test suite that exercises the integration points between the app and the database.
1. The data ingestion, which is defined in the `ingest` directory and is a standard dlt project to load data from an upstream database into a local DuckDB instance.
1. The data transformation, which is defined in the `transform` directory and is a standard dbt-duckdb project that transforms the data in the DuckDB tables.
1. The integration tests, which are defined in the `root` directory which contains the [Docker Compose](https://docs.docker.com/compose/) configuration 
for running the web service and data pipeline together.

The simplest way to get started is to execute the `run.sh` script in the `root` directory, which will
build the Docker images for the web service and data pipeline, run them in Docker Compose, and execute the test suite and pipeline.

## Quickstart

    # Clone the repo
    git clone https://github.com/jwills/shift_yourself_left.git

and

    # Run the integration tests
    ./run.sh

## Integration Tests Overview

* `./run.sh app` runs the web app. You can interact with it at http://localhost:8000/.
* `./run.sh app_tests` runs the [pytest](https://docs.pytest.org/) test suite that exercises the web service API.
* `./run.sh ingest` runs the "app_tests" and then data ingestion with dlt .
* `./run.sh transform` runs the data transformation with dbt (and the two steps before in order to generate the test data).
  * If this succeeds then the end-to-end integration test has passed.
