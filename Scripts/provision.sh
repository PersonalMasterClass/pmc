#!/bin/bash
# This script is used to provision and configure a fresh CentOS 7 VM.
# As this script assumes an atomic deployment, everything will be installed.

APP_USER="pmc" # System account, also used for database
BRANCH="master"
CWD="$(pwd)"
NGINX_USER="nginx"
PASSENGER_CONFIG_FILE="/etc/nginx/conf.d/passenger.conf"
PMC_DB_USER="${APP_USER}"
PMC_DB_HOST="localhost"
POSTGRESQL_DATA_DIR="/var/lib/pgsql/data"
POSTGRESQL_HBA_FILE="${POSTGRESQL_DATA_DIR}/pg_hba.conf"
POSTGRESQL_PASSWORD=""
POSTGRESQL_USER="${APP_USER}"
REPOSITORY_URL="https://github.com/PersonalMasterClass/pmc.git"
RUBY_VERSION_STRING="2.3.1"
S3_SECRET_KEY=""
S3_ACCESS_SECRET=""
S3_BUCKET="personalmasterclass"
S3_REGION="ap-southeast-2"
SMTP_ADDRESS="email-smtp.us-west-2.amazonaws.com"
SMTP_PORT="587"
SMTP_USERNAME=""
SMTP_PASSWORD=""
SECRET_KEY_FILE="/usr/local/etc/pmc_secret_key"
SSL_CERT_BUNDLE="personalmasterclass.crt"  # The certificate bundle file as it exists relative to this provisioning script
SSL_CERT_KEY="personalmasterclass.key"     # The certificate private key as it exists relative to this provisioning script
XERO_PRIVATE_KEY="privatekey.pem"          # The XERO private key as it exists relative to this provsioning script
WEB_ROOT="/var/www/html"
XERO_CONSUMER_KEY=""
XERO_SECRET_KEY=""
MAILER_SENDER=""

LOG_FILE="/usr/local/pmc_provisioning.log"

ADDUSER="/sbin/adduser"
CAT="/bin/cat"
CHCON="/bin/chcon"
CHMOD="/bin/chmod"
CHOWN="/bin/chown"
CP="/usr/bin/cp"
CREATEDB="/usr/bin/createdb"
CREATEUSER="/usr/bin/createuser"
CURL="/usr/bin/curl"
DIRNAME="/usr/bin/dirname"
FIND="/bin/find"
GIT="/usr/bin/git"
MKDIR="/bin/mkdir"
POSTGRESQL_SETUP="/usr/bin/postgresql-setup"
PSQL="/bin/psql"
RVM="/usr/local/rvm/bin/rvm"
RVMSUDO="${RVM}sudo"
SUDO="/usr/bin/sudo"
SYSTEMCTL="/usr/bin/systemctl"
USERMOD="/sbin/usermod"
WC="/bin/wc"
YUM="/usr/bin/yum"
YUM_MGR="/usr/bin/yum-config-manager"

function log() {
  echo "${1}"
  echo "${1}" >> "${LOG_FILE}"
}
function showHelp() {
  echo "Usage: ${0##*/} [-h] [-p postgresql_password] [-u postgresql_user]"
  echo "  -b:  Select the branch to pull from."
  echo "  -h:  Show this help text."
  echo "  -p:  The PostgreSQL password."
  echo "  -s:  The Amazon S3 Secret Key."
  echo "  -t:  The Amazon S3 Access Secret."
  echo "  -u:  The PostgreSQL user. A database with the same name will be created."
}

if [ "${EUID}" != 0 ]; then
  >&2 echo "This script must be run as root. Terminating."
  cd "${CWD}"
  exit 1
fi

while getopts "b:b h m:m p:p q:q r:r s:s t:t u:u x:x y:y" flag
do
  case $flag in
    b)  BRANCH="${OPTARG}";;
    h)  showHelp ; exit 0;;
    m)  MAILER_SENDER="${OPTARG}";;
    p)  POSTGRESQL_PASSWORD="${OPTARG}";;
    q)  S3_BUCKET="${OPTARG}";;
    r)  S3_REGION="${OPTARG}";;
    s)  S3_SECRET_KEY="${OPTARG}";;
    t)  S3_ACCESS_SECRET="${OPTARG}";;
    u)  POSTGRESQL_USER="${OPTARG}";;
    x)  XERO_CONSUMER_KEY="${OPTARG}";;
    y)  XERO_SECRET_KEY="${OPTARG}";;
  esac
done

# Export things for environment usage later down the track
export RAILS_ENV="production"
export PMC_DB_PASSWORD="${POSTGRESQL_PASSWORD}"
export PMC_DB_USER="${POSTGRESQL_USER}"
export PMC_DB_NAME="${POSTGRESQL_USER}"
export PMC_DB_HOST
export rvmsudo_secure_path=0

# Load in the environment variables into /etc/profile.d, and lock it down
VARFILE="/etc/profile.d/pmc.sh"
echo "export SECRET_KEY_BASE=${SECRET_KEY_BASE}
export PMC_DB_NAME=${POSTGRESQL_USER}
export PMC_DB_USER=${POSTGRESQL_USER}
export PMC_DB_PASSWORD=${POSTGRESQL_PASSWORD}
export PMC_DB_HOST=localhost
export S3_KEY=${S3_SECRET_KEY}
export S3_SECRET=${S3_ACCESS_SECRET}
XERO_CONSUMER_KEY=${XERO_CONSUMER_KEY}
XERO_SECRET_KEY=${XERO_SECRET_KEY}" > "${VARFILE}"
"${CHOWN}" root:root "${VARFILE}"
"${CHMOD}" 711 "${VARFILE}"

log "Beginning provisioning at $(date)"
log "Installing updates..."
# Run updates
"${YUM}" update -y
"${YUM}" -y install yum-utils epel-release

# Set up the system user
log "Creating the '${APP_USER}' system user"
"${ADDUSER}" -r "${APP_USER}"
"${USERMOD}" -d "${WEB_ROOT}" -aG "${NGINX_USER}" "${APP_USER}"

# Enable external repositories
log "Enabling external repositories..."
if ! rpm -q epel-release; then "${YUM_MGR}" --enable epel; fi
"${CURL}" --fail -sSLo /etc/yum.repos.d/passenger.repo \
  https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo

# Install the webserver environment first
log "Installing webserver environment..."
"${YUM}" -y install nginx

# Install RVM so we can manage ruby versions
log "Installing dependencies for RVM..."
"${YUM}" -y install curl gpg gcc gcc-c++ make
log "Installing Ruby via RVM..."
GPG_DIR="${HOME}/.gnupg"
if [ ! -d "${GPG_DIR}" ]; then
  mkdir "${GPG_DIR}"
  chown "${NGINX_USER}":"${NGINX_USER}" "${GPG_DIR}"
fi
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer | bash -s stable --ruby="${RUBY_VERSION_STRING}"
for i in "/bin/ruby" "/usr/bin/ruby"; do
  if [ -f "${i}" ]; then rm "${i}"; fi
  ln -s /usr/local/rvm/rubies/default/bin/ruby "${i}"
done
source /usr/local/rvm/scripts/rvm
"${RVMSUDO}" "${RVM}" use "${RUBY_VERSION_STRING}" --default

/sbin/usermod -aG rvm "${NGINX_USER}"
/sbin/usermod -aG rvm "${APP_USER}"

log "Installing other dependencies..."
"${YUM}" -y install \
  postgresql postgresql-server postgresql-devel postgresql-contrib \
  git \
  pygpgme \
  curl \
  passenger \
  zlib zlib-devel \
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
if ! "${SYSTEMCTL}" is-enabled postgresql.service > /dev/null 2>&1; then
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
"${CHOWN}" "${NGINX_USER}": /var/lib/nginx/.pgpass

# Configure Passenger
# https://www.phusionpassenger.com/library/install/nginx/install/oss/el7/
log "Configuring Phusion Passenger..."
echo "
passenger_root /usr/share/ruby/vendor_ruby/phusion_passenger/locations.ini;
passenger_ruby /usr/local/rvm/gems/ruby-"${RUBY_VERSION_STRING}"/wrappers/ruby;
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
export HOME="${WEB_ROOT}"
"${GIT}" checkout -f "${BRANCH}"
"${GIT}" pull

"${CHCON}" -R -h -t httpd_sys_content_t "${WEB_ROOT}"

# Set permissions
log "Setting permissions for web root..."
PARENT_DIR="$(${DIRNAME} ${WEB_ROOT})"
"${CHOWN}" -R "${NGINX_USER}": "${PARENT_DIR}"
"${FIND}" "${WEB_ROOT}" -type d -exec "${CHMOD}" 775 {} \;
"${FIND}" "${WEB_ROOT}" -type f -exec "${CHMOD}" 664 {} \;

log "Installing rails dependencies..."
"${RVMSUDO}" "${RVM}" "${RUBY_VERSION_STRING}" do gem update --system
"${RVMSUDO}" "${RVM}" "${RUBY_VERSION_STRING}" do gem install rails bundle bundler

log "Installing gems in Gemfile..."
"${RVMSUDO}" "${RVM}" "${RUBY_VERSION_STRING}" do bundle install --deployment

log "Ensuring that the secret key base exists..."
if [ -f "${SECRET_KEY_FILE}" ]; then
  SECRET_KEY_BASE="$(${CAT} ${SECRET_KEY_FILE})"
else
  export SECRET_KEY_BASE="$(${SUDO} -iu ${NGINX_USER} ${RVM} ${RUBY_VERSION_STRING} do bundle exec rake secret)"
  echo "${SECRET_KEY_BASE}" > "${SECRET_KEY_FILE}"
fi
export SECRET_KEY_BASE="${SECRET_KEY_BASE}"

log "Configuring redis..."
"${SYSTEMCTL}" enable redis
"${SYSTEMCTL}" start redis

if [ -f "${CWD}/${SSL_CERT_KEY}" ]; then
  log "Installing certificate private key..."
  DEST_FILE="/etc/nginx/personalmasterclass.key"
  "${CP}" "${CWD}/${SSL_CERT_KEY}" /etc/nginx/personalmasterclass.key &&
  "${CHOWN}" root:root "${DEST_FILE}"
  "${CHMOD}" 600 "${DEST_FILE}"
fi
if [ -f "${CWD}/${SSL_CERT_BUNDLE}" ]; then
  log "Installing certificate bundle..."
  DEST_FILE="/etc/nginx/personalmasterclass.crt"
  "${CP}" "${CWD}/${SSL_CERT_BUNDLE}" /etc/nginx/personalmasterclass.crt &&
  "${CHOWN}" root:root "${DEST_FILE}"
  "${CHMOD}" 600 "${DEST_FILE}"
fi
if [ -f "${CWD}/${XERO_PRIVATE_KEY}" ] && [ -d "${WEB_ROOT}/config" ]; then
  "${CP}" "${CWD}/${XERO_PRIVATE_KEY}" "${WEB_ROOT}/config/privatekey.pem"
fi

if [ -f "/etc/nginx/${SSL_CERT_KEY}" ] && [ -f "/etc/nginx/${SSL_CERT_BUNDLE}" ]; then
  SSL_PRESENT=true
fi

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
    passenger_default_user \"${NGINX_USER}\";
    passenger_default_group \"${NGINX_USER}\";
    server {
      listen        80 default_server;" > /etc/nginx/nginx.conf
if [ "${SSL_PRESENT}" = true ]; then
  echo "return    301 https://personalmasterclass.com\$request_uri;
    }
    server {
      listen        443 default_server;
      ssl                          on;
      ssl_certificate              /etc/nginx/personalmasterclass.crt;
      ssl_certificate_key          /etc/nginx/personalmasterclass.key;
      ssl_protocols                TLSv1 TLSv1.1 TLSv1.2;
      ssl_ciphers                  HIGH:MEDIUM;
      ssl_prefer_server_ciphers    on;" >> /etc/nginx/nginx.conf
fi
echo "
      server_name    localhost;
      root           ${WEB_ROOT}/public;

      charset utf-8;

      access_log  /var/log/nginx/access.log  main;
      
      passenger_enabled on;
      passenger_user \"${NGINX_USER}\";
      passenger_group \"${NGINX_USER}\";
      passenger_app_env \"production\";
      passenger_env_var SECRET_KEY_BASE \"${SECRET_KEY_BASE}\";
      passenger_env_var PMC_DB_NAME \"${POSTGRESQL_USER}\";
      passenger_env_var PMC_DB_USER \"${POSTGRESQL_USER}\";
      passenger_env_var PMC_DB_PASSWORD \"${POSTGRESQL_PASSWORD}\";
      passenger_env_var PMC_DB_HOST \"localhost\";
      passenger_env_var S3_REGION \"${S3_REGION}\";
      passenger_env_var S3_BUCKET \"${S3_BUCKET}\";
      passenger_env_var S3_KEY \"${S3_SECRET_KEY}\";
      passenger_env_var S3_SECRET \"${S3_ACCESS_SECRET}\";
      passenger_env_var xero_consumer \"${XERO_CONSUMER_KEY}\";
      passenger_env_var xero_secret \"${XERO_SECRET_KEY}\";
      passenger_env_var xero_cert_location \"config/xero_privatekey.pem\";
      passenger_env_var MAILER_SENDER \"${MAILER_SENDER}\";
    }
}" >> /etc/nginx/nginx.conf

# Set a few permissions things if they haven't been already
PGPASS_FILE="/var/lib/nginx/.pgpass"
if [ -f "${PGPASS_FILE}" ]; then
  "${CHMOD}" 600 "${PGPASS_FILE}"
fi

log "Compiling static assets..."
"${RVMSUDO}" -E "${RVM}" "${RUBY_VERSION_STRING}" do bundle exec rake assets:precompile

log "Running migrations..."
"${RVMSUDO}" -E "${RVM}" "${RUBY_VERSION_STRING}" do bundle exec rake db:migrate

"${CHOWN}" -R "${NGINX_USER}":"${NGINX_USER}" "${WEB_ROOT}"

log "Restarting nginx..."
"${SYSTEMCTL}" restart nginx

log "Provisioning ended at $(date)."
cd "${CWD}"