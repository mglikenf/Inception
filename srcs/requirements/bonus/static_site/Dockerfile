FROM alpine:3.22

RUN apk add --no-cache busybox-extras

COPY files /var/www

WORKDIR /var/www

EXPOSE 8080

CMD ["httpd", "-f", "-p", "8080", "-h", "/var/www"]
