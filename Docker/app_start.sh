#!/bin/bash
source "$(git rev-parse --show-toplevel)/Docker/app_source.sh"
for component in "${APP_COMPONENTS[@]}"; do
	NAME="${APP_PREFIX}_${component}"
	docker run -d --name "${NAME}" "${NAME}"
done && 
sleep 2 &&
docker run -d -p 3000:3000 -e RAILS_ENV=development -e REDIS_URL="redis://${APP_PREFIX}_redis" --link="${APP_PREFIX}_redis" --link="${APP_PREFIX}_postgres" --name "${APP_PREFIX}" "${APP_PREFIX}";
