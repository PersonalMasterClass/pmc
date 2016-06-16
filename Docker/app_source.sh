#!/bin/bash
export APP_PREFIX="pmc"
export WORKING_DIR="$(pwd)"
export REPO_ROOT="$(git rev-parse --show-toplevel)"
if [ -f $(which docker-machine 2>/dev/null) ]; then
	eval $(docker-machine env)
fi
