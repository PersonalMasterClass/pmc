#!/bin/bash
CONTAINER_NAME="pmc"
if [ "${1}" != "" ]; then CONTAINER_NAME="${1}"; fi
# Step 1 - Copy all the new files over
docker cp "$(git rev-parse --show-toplevel)" "${CONTAINER_NAME}":"/usr/src/app" &&
# Step 2 - Run rails migrations - Make sure that you're using the right container name.
docker exec "${CONTAINER_NAME}" rake db:migrate
