#!/bin/bash
docker run -d -p 3000:3000 -e REDIS_URL="redis://172.17.0.1" --name pmc pmc
