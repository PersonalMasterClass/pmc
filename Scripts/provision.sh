#!/bin/bash
# This script is used to provision and configure a fresh CentOS 7 VM.
# As this script assumes an atomic deployment, everything will be installed.

LOG_FILE="/usr/local/pmc_provisioning.log"

BUNDLE="/usr/local/bin/bundle"
CAT="/bin/cat"
CHMOD="/bin/chmod"
CHOWN="/bin/chown"
CREATEDB="/usr/bin/createdb"
CREATEUSER="/usr/bin/createuser"
CURL="/usr/bin/curl"
DIRNAME="/usr/bin/dirname"
FIND="/bin/find"
GEM="/usr/bin/gem"
GIT="/usr/bin/git"
MKDIR="/bin/mkdir"
POSTGRESQL_SETUP="/usr/bin/postgresql-setup"
PSQL="/bin/psql"
SUDO="/usr/bin/sudo"
SYSTEMCTL="/usr/bin/systemctl"
WC="/bin/wc"
YUM="/usr/bin/yum"
YUM_MGR="/usr/bin/yum-config-manager"

CWD="$(pwd)"
NGINX_USER="nginx"
PASSENGER_CONFIG_FILE="/etc/nginx/conf.d/passenger.conf"
POSTGRESQL_DATA_DIR="/var/lib/pgsql/data"
POSTGRESQL_PASSWORD=""
POSTGRESQL_USER="pmc"
POSTGRESQL_HBA_FILE="${POSTGRESQL_DATA_DIR}/pg_hba.conf"
REPOSITORY_URL="https://github.com/PersonalMasterClass/pmc.git"
SECRET_KEY_FILE="/usr/local/etc/pmc_secret_key"
WEB_ROOT="/var/www/html"

export RAILS_ENV="production"
export HOME="${WEB_ROOT}"

function log() {
  echo "${1}"
  echo "${1}" >> "${LOG_FILE}"
}
function showHelp() {
  echo "Usage: ${0##*/} [-h] [-p postgresql_password] [-u postgresql_user]"
  echo "  -h:  Show this help text."
  echo "  -p:  The PostgreSQL password."
  echo "  -u:  The PostgreSQL user. A database with the same name will be created."
}

if [ "${EUID}" != 0 ]; then
  >&2 echo "This script must be run as root. Terminating."
  exit 1
fi

while getopts "h p:p u:u" flag
do
  case $flag in
    h)  showHelp ; exit 0;;
    p)  POSTGRESQL_PASSWORD="${OPTARG}";;
    u)  POSTGRESQL_USER="${OPTARG}";;
  esac
done

log "Beginning provisioning at $(date)"
log "Installing updates..."
# Run updates
"${YUM}" update -y
"${YUM}" -y install yum-utils epel-release

# Enable external repositories
log "Enabling external repositories..."
if ! rpm -q epel-release; then "${YUM_MGR}" --enable epel; fi
"${CURL}" --fail -sSLo /etc/yum.repos.d/passenger.repo \
  https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo

# Install depedencies
log "Installing depedencies..."
"${YUM}" -y install \
  postgresql postgresql-server postgresql-devel postgresql-contrib \
  git \
  pygpgme \
  curl \
  nginx \
  passenger \
  ruby ruby-devel \
  zlib zlib-devel \
  gcc gcc-c++ \
  sudo \
  redis \
  v8 v8-devel

# Disable SELinux, as it causes issues with PostgreSQL
echo "SELINUX=permissive
SELINUXTYPE=targeted" > "/etc/sysconfig/selinux"

# Configure PostgreSQL
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-7
log "Setting up the PostgreSQL service..."
if [ "$(${FIND} ${POSTGRESQL_DATA_DIR} -empty | ${WC} -l)" -gt 0 ]; then
  log "Initialising the PostgreSQL data directory..."
  "${POSTGRESQL_SETUP}" initdb
fi
echo "
local   all             postgres                                trust
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
" > "${POSTGRESQL_HBA_FILE}"
if ! "${SYSTEMCTL}" is-enabled postgresql.service; then
  "${SYSTEMCTL}" enable postgresql.service &&
  "${SYSTEMCTL}" start postgresql.service
else
  "${SYSTEMCTL}" condrestart postgresql.service
fi
log "Configuring PostgreSQL..."
"${SUDO}" -E -u postgres "${CREATEUSER}" "${POSTGRESQL_USER}"
"${SUDO}" -E -u postgres "${CREATEDB}" "${POSTGRESQL_USER}"
"${SUDO}" -E -u postgres "${PSQL}" -d "${POSTGRESQL_USER}" \
  -c "ALTER USER \"${POSTGRESQL_USER}\" WITH PASSWORD '${POSTGRESQL_PASSWORD}';"
echo "localhost:5432:${POSTGRESQL_USER}:${POSTGRESQL_USER}:${POSTGRESQL_PASSWORD}" > /var/lib/nginx/.pgpass

# Configure Passenger
# https://www.phusionpassenger.com/library/install/nginx/install/oss/el7/
log "Configuring Phusion Passenger..."
echo "
passenger_root /usr/share/ruby/vendor_ruby/phusion_passenger/locations.ini;
passenger_ruby $(which ruby);
passenger_instance_registry_dir /var/run/passenger-instreg;" > "${PASSENGER_CONFIG_FILE}"

if [ ! -d "${WEB_ROOT}" ]; then
  log "Creating web root"
  "${MKDIR}" -p "${WEB_ROOT}"
fi

if [ ! -d "${WEB_ROOT}/.git" ]; then
  log "Cloning into ${WEB_ROOT}"
  "${GIT}" clone "${REPOSITORY_URL}" "${WEB_ROOT}"
fi

cd "${WEB_ROOT}"
"${GIT}" pull

# Set permissions
log "Setting permissions for web root..."
PARENT_DIR="$(${DIRNAME} ${WEB_ROOT})"
"${CHOWN}" -R "${NGINX_USER}":"${NGINX_USER}" "${PARENT_DIR}"
"${FIND}" "${WEB_ROOT}" -type d -exec "${CHMOD}" 755 {} \;
"${FIND}" "${WEB_ROOT}" -type f -exec "${CHMOD}" 751 {} \;
if [ -f "${SECRET_KEY_FILE}" ]; then
  SECRET_KEY_BASE="$(${CAT} ${SECRET_KEY_FILE})"
else
  export SECRET_KEY_BASE="$(${SUDO} -u ${NGINX_USER} ${BUNDLE} exec rake secret)"
  echo "${SECRET_KEY_BASE}" > "${SECRET_KEY_FILE}"
fi

log "Installing rails dependencies..."
"${SUDO}" -E -u "${NGINX_USER}" "${GEM}" install bundle

log "Installing gems in Gemfile..."
cd "${WEB_ROOT}" &&
"${SUDO}" -E -u "${NGINX_USER}" "${BUNDLE}" install

log "Compiling static assets..."
"${SUDO}" -E -u "${NGINX_USER}" "${BUNDLE}" exec rake assets:precompile \
  SECRET_KEY_BASE="${SECRET_KEY_BASE}" \
  RAILS_ENV="production"

log "Running migrations..."
"${SUDO}" -E -u "${NGINX_USER}" "${BUNDLE}" exec rake db:migrate \
  SECRET_KEY_BASE="${SECRET_KEY_BASE}" \
  PMC_DB_USER="${POSTGRESQL_USER}" \
  PMC_DB_PASSWORD="${POSTGRESQL_PASSWORD}" \
  PMC_DB_NAME="${POSTGRESQL_USER}" \
  RAILS_ENV="production"

log "Configuring redis..."
"${SYSTEMCTL}" enable redis
"${SYSTEMCTL}" start redis

log "Configuring nginx..."
"${CHMOD}" 700 "${SECRET_KEY_FILE}"
"${CHOWN}" root:root "${SECRET_KEY_FILE}"
echo "user  ${NGINX_USER};
worker_processes  1;

error_log  /var/log/nginx/error.log;
#error_log  /var/log/nginx/error.log  notice;
#error_log  /var/log/nginx/error.log  info;

pid        /run/nginx.pid;

events {
    worker_connections  1024;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    index   index.html index.htm;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80 default_server;
        server_name  localhost;
        root         ${WEB_ROOT}/public;

        charset utf-8;

        access_log  /var/log/nginx/access.log  main;

        location / {

        }
        passenger_enabled on;
        passenger_user \"${NGINX_USER}\";
        passenger_group \"${NGINX_USER}\";
        passenger_app_env \"production\";
        passenger_env_var SECRET_KEY_BASE \"${SECRET_KEY_BASE}\";
        passenger_env_var PMC_DB_NAME \"${POSTGRESQL_USER}\";
        passenger_env_var PMC_DB_USER \"${POSTGRESQL_USER}\";
        passenger_env_var PMC_DB_PASSWORD \"${POSTGRESQL_PASSWORD}\";
        passenger_env_var PMC_DB_HOST \"localhost\";
    }
}
" > /etc/nginx/nginx.conf

log "Restarting nginx..."
"${SYSTEMCTL}" restart nginx

log "Provisioning ended at $(date)."
cd "${CWD}"