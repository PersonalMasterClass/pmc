#!/bin/bash
source "$(git rev-parse --show-toplevel)/Docker/app_source.sh"
cd "${REPO_ROOT}" &&
"${REPO_ROOT}/Docker/app_build.sh" &&
docker rm -f "${APP_PREFIX}" > /dev/null 2>&1
for component in "${APP_COMPONENTS[@]}"; do
	docker rm -f "${APP_PREFIX}_${component}" > /dev/null 2>&1
done
"${REPO_ROOT}/Docker/app_start.sh"
sleep 2;
docker exec pmc bundle exec rake db:migrate;
docker exec pmc bundle exec rake db:seed;
cd "${WORKING_DIR}"
