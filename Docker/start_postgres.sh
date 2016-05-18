#!/bin/bash
docker run -d -e POSTGRES_USER="pmc" -e POSTGRES_DB="pmc" --name pmc_postgres postgres
