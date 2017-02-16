docker build -t pmc_redis -f /usr/src/app/Docker/Dockerfile_redis /usr/src/app &&
docker create --name pmc_redis pmc_redis
