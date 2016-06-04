#!/bin/bash
source "$(git rev-parse --show-toplevel)/Docker/app_source.sh"
cd "${REPO_ROOT}" &&
"${REPO_ROOT}/Docker/app_build.sh" &&
docker rm -f "${APP_PREFIX}" "${APP_PREFIX}_postgres" "${APP_PREFIX}_redis" > /dev/null 2>&1
"${REPO_ROOT}/Docker/app_start.sh"
sleep 2;
docker exec pmc bundle exec rake db:migrate;
docker exec pmc bundle exec rake db:seed;
cd "${WORKING_DIR}"
