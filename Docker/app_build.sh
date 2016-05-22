#!/bin/bash
source "$(git rev-parse --show-toplevel)/Docker/app_source.sh"
cd "${REPO_ROOT}" &&
docker build -t "${APP_PREFIX}" . &&
for component in "${APP_COMPONENTS[@]}"; do
	docker build -t "${APP_PREFIX}_${component}" -f "${REPO_ROOT}/Docker/Dockerfile_${component}" .
done
cd "${WORKING_DIR}"
