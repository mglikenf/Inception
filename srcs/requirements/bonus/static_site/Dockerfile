FROM alpine:3.22

RUN apk add --no-cache busybox-extras tini && \
	adduser -D -u 1000 unprivileged && \
	mkdir -p /var/www && \
	chown -R unprivileged:unprivileged /var/www

COPY files /var/www

RUN chown -R unprivileged:unprivileged /var/www

USER unprivileged

WORKDIR /var/www

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["httpd", "-f", "-p", "8080", "-h", "/var/www"]
