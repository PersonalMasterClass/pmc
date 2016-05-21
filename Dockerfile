FROM rails:onbuild

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

RUN rake assets:precompile
