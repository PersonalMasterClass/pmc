#!/bin/bash
docker run -d -p 3000:3000 --link=pmc_postgres --link=pmc_redis --name pmc pmc
