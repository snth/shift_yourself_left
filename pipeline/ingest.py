import humanize
import os

import dlt
from dlt.sources.credentials import ConnectionStringCredentials
from dlt.sources.sql_database import sql_database


def load_entire_database() -> None:
    """Use the sql_database source to completely load all tables in a database"""
    pipeline = dlt.pipeline(pipeline_name="shift_yourself_left", destination='duckdb', dataset_name="recipes_raw")

    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise ValueError("DATABASE_URL is not set")
    credentials = ConnectionStringCredentials(database_url)
    source = sql_database(credentials)

    # Run the pipeline. For a large db this may take a while
    info = pipeline.run(source, write_disposition="replace")
    print(humanize.precisedelta(pipeline.last_trace.finished_at - pipeline.last_trace.started_at))
    print(info)
    print(info.metrics)


if __name__ == "__main__":
    load_entire_database()
