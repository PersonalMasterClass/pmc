FROM rails:4.2

# (Example) Environment variables for Rails
ENV RAILS_ENV 'development'
ENV REDIS_URL 'redis://pmc_redis'
ENV SECRET_KEY_BASE 'youshouldreallyoverridethiswhenrunningthecontainerorwhendeployed'
ENV S3_REGION ''
ENV S3_BUCKET ''
ENV S3_KEY ''
ENV S3_SECRET ''
ENV xero_consumer ''
ENV xero_secret ''
ENV xero_cert_location ''
ENV SMTP_ADDRESS "email-smtp.us-west-2.amazonaws.com"
ENV SMTP_PORT "587"
ENV SMTP_USERNAME ""
ENV SMTP_PASSWORD ""

# (Default) Database Environment Variables
ENV PMC_DB_HOST 'pmc_postgres'
ENV PMC_DB_NAME 'pmc'
ENV PMC_DB_USER 'pmc'
ENV PMC_DB_PASSWORD 'changeme123'

# Taken from the master Dockerfile: https://github.com/docker-library/rails/blob/master/onbuild/Dockerfile
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

RUN apt-get update && apt-get install -y postgresql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

# Post-build commands
# The line below is only required for production environments.
#RUN rake assets:precompile
