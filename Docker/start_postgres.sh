#!/bin/bash
docker run -d -p 5432:5432 -e POSTGRES_USER="root" -e POSTGRES_DB="pmc_development" --name db postgres
