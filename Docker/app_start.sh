#!/bin/bash
source "$(git rev-parse --show-toplevel)/Docker/app_source.sh"
docker run -d --name "${APP_PREFIX}_postgres" "${APP_PREFIX}_postgres" &&
docker run -d --name "${APP_PREFIX}_redis" "${APP_PREFIX}_redis" &&
sleep 2 &&
docker run -d -p 3000:3000 -e RAILS_ENV=development -e REDIS_URL="redis://${APP_PREFIX}_redis" --link="${APP_PREFIX}_redis" --link="${APP_PREFIX}_postgres" --name "${APP_PREFIX}" "${APP_PREFIX}";
