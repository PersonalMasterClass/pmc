#!/bin/bash
eval $(docker-machine env)
export APP_PREFIX="pmc"
export APP_COMPONENTS=( 'redis' 'postgres' )
export WORKING_DIR="$(pwd)"
export REPO_ROOT="$(git rev-parse --show-toplevel)"