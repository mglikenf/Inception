FROM alpine:3.22

RUN apk add --no-cache busybox-extras tini

COPY files /var/www

WORKDIR /var/www

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["httpd", "-f", "-p", "8080", "-h", "/var/www"]
