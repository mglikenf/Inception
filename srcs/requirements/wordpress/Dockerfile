FROM alpine:3.22

RUN apk add --no-cache \
    php84 \
	php84-fpm \
	php84-mysqli \
	php84-phar \
	php84-curl \
	php84-dom \
	php84-exif \
	php84-fileinfo \
	php84-mbstring \
	php84-xml \
	php84-zip \
	php84-tokenizer \
	php84-session \
	php84-iconv \
	php84-gd \
	php84-xmlwriter \
	php84-xmlreader \
	php84-simplexml \
	wget \
	curl \
	netcat-openbsd

RUN ln -s /usr/bin/php84 /usr/bin/php

RUN echo "memory_limit = 256M" >> /etc/php84/php.ini

RUN mkdir -p /var/www/html

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php84/php-fpm.d/www.conf
COPY tools/setup-wordpress.sh /usr/local/bin/setup-wordpress.sh
RUN chmod +x /usr/local/bin/setup-wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/usr/local/bin/setup-wordpress.sh"]
