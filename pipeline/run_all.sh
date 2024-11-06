#!/bin/bash

python3 ingest.py
dbt build
