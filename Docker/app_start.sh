docker run -d --name pmc_redis pmc_redis;
docker run -d --name pmc_postgres pmc_postgres;
sleep 2;
docker run -d -p 3000:3000 -e RAILS_ENV=development -e REDIS_URL="redis://pmc_redis" --link=pmc_redis --link=pmc_postgres --name pmc pmc;
