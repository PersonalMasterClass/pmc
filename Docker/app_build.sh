#!/bin/bash
source "$(git rev-parse --show-toplevel)/Docker/app_source.sh"
cd "${REPO_ROOT}" &&
docker build -t "${APP_PREFIX}" "${REPO_ROOT}" &&
docker build -t "${APP_PREFIX}_postgres" -f "${REPO_ROOT}/Docker/Dockerfile_postgres" "${REPO_ROOT}" &&
docker build -t "${APP_PREFIX}_redis" -f "${REPO_ROOT}/Docker/Dockerfile_redis" "${REPO_ROOT}" &&
cd "${WORKING_DIR}"
