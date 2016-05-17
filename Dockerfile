FROM rails:onbuild
# 172.17.0.1 is the default Docker bridge IP, allowing us to connect docker containers via the bridge.
RUN /bin/sed -i 's/#host: localhost/host: 172.17.0.1/g' /usr/src/app/config/database.yml
ENV REDIS_URL 'redis:///172.17.0.1'
