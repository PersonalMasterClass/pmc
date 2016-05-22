CWD="$(pwd)"
cd "$(git rev-parse --show-toplevel)" &&
eval $(cat Docker/app_build.sh) &&
docker rm -f pmc pmc_redis pmc_postgres > /dev/null 2>&1;
eval $(cat Docker/app_start.sh);
sleep 2;
docker exec pmc bundle exec rake db:migrate;
docker exec pmc bundle exec rake db:seed;
cd "${CWD}"
