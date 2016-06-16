#!/bin/bash
source "$(git rev-parse --show-toplevel)/Docker/app_source.sh"
DFILE="${REPO_ROOT}/Dockerfile"
TESTFILE="${DFILE}_test"

if [ -f "${TESTFILE}" ]; then
	echo "Building with test file '${TESTFILE}'"
	DFILE="${TESTFILE}"
fi

cd "${REPO_ROOT}" &&
docker build -t "${APP_PREFIX}" -f "${DFILE}" "${REPO_ROOT}" &&
docker build -t "${APP_PREFIX}_postgres" -f "${REPO_ROOT}/Docker/Dockerfile_postgres" "${REPO_ROOT}" &&
docker build -t "${APP_PREFIX}_redis" -f "${REPO_ROOT}/Docker/Dockerfile_redis" "${REPO_ROOT}" &&
cd "${WORKING_DIR}"
