#!/bin/bash
source "$(git rev-parse --show-toplevel)/Docker/app_source.sh"
CONTAINER_NAME="pmc"
# Step 1 - Copy all the new files over
docker cp "$(git rev-parse --show-toplevel)" "${CONTAINER_NAME}:/usr/src/app" &&
# Step 2 - Run rails migrations - Make sure that you're using the right container name.
docker exec "${CONTAINER_NAME}" rake db:migrate
# Step 3 - Build the rake assets
docker exec "${CONTAINER_NAME}" rake assets:precompile
