FROM alpine:3.22

RUN apk add --no-cache redis

COPY conf/redis.conf /etc/redis.conf
RUN chown redis:redis /etc/redis.conf

USER redis
WORKDIR /data

EXPOSE 6379

CMD [ "redis-server", "/etc/redis.conf" ]
