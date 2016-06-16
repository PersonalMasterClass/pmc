#!/bin/bash
export APP_PREFIX="pmc"
export WORKING_DIR="$(pwd)"
export REPO_ROOT="$(git rev-parse --show-toplevel)"
DM="$(which docker-machine)"
if [ "${DM}" != "" ] && [ -f "${DM}" ] && [ -x "${DM}" ]; then
	eval $(${DM} env)
fi
