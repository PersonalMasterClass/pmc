FROM rails:4.2

# Environment variables for Rails
ENV RAILS_ENV 'test'
ENV REDIS_URL 'redis:///pmc_redis'
ENV SECRET_KEY_BASE 'youshouldreallyoverridethiswhenrunningthecontainerorwhendeployed'

# (Default) Database Environment Variables
ENV RDS_HOST 'pmc_postgres'
ENV RDS_NAME 'pmc'
ENV RDS_USERNAME 'pmc'
ENV RDS_PASSWORD 'thisshouldmostcertainlybechangedviaelasticbeanstalk'
ENV RDS_PORT '5432'

# Taken from the master Dockerfile: https://github.com/docker-library/rails/blob/master/onbuild/Dockerfile
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

# Post-build commands
# The line below is only required for production environments.
#RUN rake assets:precompile
