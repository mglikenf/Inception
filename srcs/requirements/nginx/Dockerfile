FROM alpine:3.22

RUN apk add --no-cache \
    nginx \
    openssl

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out /etc/nginx/ssl/nginx.crt \
    -keyout /etc/nginx/ssl/nginx.key \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Student/CN=localhost/UID=mglikenf"

RUN mkdir -p /var/run/nginx

RUN mkdir -p /var/www/html

COPY /conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
