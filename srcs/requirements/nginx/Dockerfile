FROM alpine:3.22

RUN apk add --no-cache \
    nginx \
    openssl

# Create directories as root
RUN mkdir -p /etc/nginx/ssl /var/run/nginx /var/www/html

# Generate certificate as root
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out /etc/nginx/ssl/nginx.crt \
    -keyout /etc/nginx/ssl/nginx.key \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Student/CN=localhost/UID=mglikenf"

# Copy config as root
COPY /conf/nginx.conf /etc/nginx/nginx.conf

# Give nginx user ownership of necessary directories
RUN chown -R nginx:nginx /var/www/html && \
	chown -R nginx:nginx /var/run/nginx && \
	chown -R nginx:nginx /etc/nginx/ssl

# Switch to nginx user:
USER nginx

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
