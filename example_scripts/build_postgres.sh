docker build -t pmc_postgres -f /usr/src/app/Docker/Dockerfile_postgres /usr/src/app &&
docker create --name pmc_postgres pmc_postgres
