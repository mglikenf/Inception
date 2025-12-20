FROM alpine:3.22

RUN apk add --no-cache \
	php84 \
	php84-fpm \
	php84-session \
	php84-mysqli \
	php84-json \
	wget

RUN mkdir -p /var/www/html

RUN wget -O /var/www/html/adminer.php https://www.adminer.org/latest.php && \
    chmod 644 /var/www/html/adminer.php

COPY conf/www.conf /etc/php84/php-fpm.d/www.conf

RUN sed -i 's|;daemonize = yes|daemonize = no|g' /etc/php84/php-fpm.conf

EXPOSE 9000

CMD ["php-fpm84", "-F"]
#CMD ["php84", "-S", "0.0.0.0:8080", "-t", "/var/www"]
