docker build -t pmc .;
docker rm -f pmc pmc_redis pmc_postgres > /dev/null 2>&1;
docker run -d --name pmc_redis redis;
docker run -d -e POSTGRES_USER="pmc" -e POSTGRES_DB="pmc" --name pmc_postgres postgres;
sleep 2;
docker run -d -p 3000:3000 -e REDIS_URL="redis://pmc_redis" --link=pmc_redis --link=pmc_postgres --name pmc pmc;
sleep 2;
docker exec pmc bundle exec rake db:migrate;
docker exec pmc bundle exec rake db:seed;
