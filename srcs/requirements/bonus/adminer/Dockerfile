FROM alpine:3.22

RUN apk add --no-cache \
    php83 \
	php83-fpm \
    php83-session \
    php83-mysqli \
    php83-json \
    wget

RUN mkdir -p /var/www/html

RUN wget -O /var/www/html/adminer.php https://www.adminer.org/latest.php && \
    chmod 644 /var/www/html/adminer.php

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

RUN sed -i 's|;daemonize = yes|daemonize = no|g' /etc/php83/php-fpm.conf

EXPOSE 9000

CMD ["php-fpm83", "-F"]
#CMD ["php83", "-S", "0.0.0.0:8080", "-t", "/var/www"]
