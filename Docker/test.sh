# Some useful variables
APP_NAME="pmc"
POSTGRES_NAME="${APP_NAME}_postgres"
REDIS_NAME="${APP_NAME}_redis"
DOCKER_ARGS="--host=unix:///var/run/docker.sock"

# Stop existing instances
docker $DOCKER_ARGS rm -f "${APP_NAME}" > /dev/null 2>&1
docker $DOCKER_ARGS rm -f "${POSTGRES_NAME}" > /dev/null 2>&1
docker $DOCKER_ARGS rm -f "${REDIS_NAME}" > /dev/null 2>&1

# Ensure that images are up to date
docker $DOCKER_ARGS build -t "${APP_NAME}" .
docker $DOCKER_ARGS pull redis:3.2
docker $DOCKER_ARGS pull postgres:9.5

# Start dependencies
docker $DOCKER_ARGS run -d -p 5432:5432 -e POSTGRES_USER="root" -e POSTGRES_DB="pmc_development" --name "${POSTGRES_NAME}" postgres:9.5 &&
docker $DOCKER_ARGS run -d -p 6379:6379 --name "${REDIS_NAME}" redis:3.2 &&
docker $DOCKER_ARGS run -d -p 3000:3000 --name "${APP_NAME}" "${APP_NAME}"
