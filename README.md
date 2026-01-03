# Inception

_This project has been created by @mglikenf as part of the 42 School curriculum._

A Docker-based infrastructure project that sets up a complete WordPress website with multiple services using Docker Compose.

## Description

This project is a first exercise in system administration using Docker, introducing concepts such as virtualization, containerization and orchestration.

List of present services:
- **NGINX** - Web server with TLSv1.2/TLSv1.3 SSL/TLS encryption
- **MariaDB** - Database server for WordPress
- **WordPress** - Content Management System with PHP-FPM
- **Adminer** - Database management interface
- **Redis** - Object cache for WordPress performance optimization
- **Static site** - Custom static website served through NGINX

All services run in dedicated Docker containers built from Alpine Linux 3.22 base images, and communicate on a dedicated `inception` bridge network.

## Project Requirements

This project meets the following 42 Inception requirements:
- One container per service
- Custom images built from Alpine Linux (penultimate stable version)
- Custom Dockerfiles for each service
- NGINX with TLSv1.2/TLSv1.3 only
- WordPress with PHP-FPM (without NGINX)
- Persistent volumes for database and WordPress
- Docker network for inter-service communication
- Automated restart on crash
- No passwords in Dockerfiles
- Environment variable configuration
- Domain name configuration (login.42.fr)
- Bonus: Redis cache, Adminer, static website

## Prerequisites 

- Docker
- Docker Compose
- Linux system
- Sudo access for volume directory creation

This project was executed on a Ubuntu-based virtual machine.

## Setup Instructions

### 1. Environment Configuration

The infrastructure requires a `.env` file which contains the environment variables needed to compose the containers.
A .env.example file is present inside the srcs/ directory for reference.
Create you own `.env` file at `~/.inception_config/.env`.
Replace placeholder values with your actual credentials.

### 2. Configure Domain Resolution

Make sure to add your domain to `etc/hosts`:

```bash
sudo sh -c 'echo "127.0.0.1 login.42.fr" >> /etc/hosts'
```

### 2. Build and Deploy

```bash
# Build all images and start containers
make

# Or step by step
make build # Build Docker images
make up # Start containers
```

## Makefile Commands

| Command | Description |
| `make` or `make all` | Complete setup: check env, create directories, build, and start |
| `make build` | Build all Docker images from scratch (no cache) |
| `make up` | Start all containers in detached mode |
| `make down` | Stop all running containers |
| `make clean` | Stop containers and remove volumes |
| `make fclean` | Full cleanup: remove containers, volumes, images, and data |
| `make re` | Rebuild everything from scratch (fclean + all) |
| `make logs` | View real-time logs from all containers |
| `make ps` | Show status of all containers |
Run curl -k https://login.42.fr in the terminal to check connection ('logic' should be replaced by the actual student's login), or type the website address in your browser of choice.

## Accessing Services

Once running, access the services at:
- **WordPress Site**: `https://login.42.fr`
- **WordPress Admin**: `https://login.42.fr/wp-admin`
- **Adminer**: `https://login.42.fr/adminer`
- **Static Site**: `https://login.42.fr/site`

### SSL Certificate Note

This project uses a self-signed SSL certificate. The browser will show a security warning on first visit. This is expected behavior for development environments.

## Data Persistence

All data is persisted in `~/data` using bind mounts:

- `~/data/wordpress/` - WordPress files and uploads
- `~/data/mariadb/` - Database files
- `~/data/redis/` - Redis cache data
- `~/data/static/` - Static site files

Data persists across container restarts. Use `make clean` or `make fclean` to remove.

## Service Details

### NGINX
- Runs as non-root user `nginx`
- Listens on port 443 with TLSv1.2/TLSv1.3
- Proxies PHP requests to WordPress and Adminer via FastCGI
- Proxies static site requests to static-site container

### WordPress
- PHP 8.4 with PHP-FPM
- Automated installation via WP-CLI
- Redis Object Cache integration for performance
- Creates admin and regular user accounts automatically
- Runs as unprivileged `nobody` user

### MariaDB
- Persistent database storage
- Automated database and user creation
- Configured for remote connections from containers
- Character set: utf8mb4

### Redis
- Acts as WordPress object cache
- Persistence enabled to `/data`
- No authentification (protected by isolated network)

### Adminer
- Lightweight database management interface
- Single PHP file, no configuration needed
- Access MariaDB through web interface

### Static Site
- Simple HTTP server using busybox httpd
- Serves static HTML/CSS files

## Troubleshooting

## Container won't start
```bash
# Check logs for specific container
docker logs <container_name>

# Or view all logs
make logs
```

### Database connection errors
```bash
# Verify MariaDB is running
docker exec -it mariadb mariadb -u root -p

# Check WordPress can reach database
docker exec -it wordpress nc -zv mariadb 3306
```

### Permission Issues
```bash
# Check data directory ownership
ls -la ~/data/

# Containers automatically set correct permissions on first run
```

## Security Considerations

This setup is designed for **development/evaluation** purposes:
- Self-signed SSL certificates (not trusted by browsers)
- Default passwords should be changed for production use
- Redis has no authentification
- Services run with minimal privileges where possible

## Resources

- [Docker concepts & essentials](https://docs.docker.com/get-started/)
- [Docker Build best practices](https://docs.docker.com/build/building/best-practices/) 
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile)
- [Docker Compose](https://docs.docker.com/compose/)
- [WP-CLI commands](https://developer.wordpress.org/cli/commands/)

**Official Docker images for reference**:

- [MariaDB](https://hub.docker.com/_/mariadb)
- [NGINX](https://hub.docker.com/_/nginx)
- [WordPress](https://hub.docker.com/_/wordpress)
- [Redis](https://hub.docker.com/_/redis)
- [Adminer](https://hub.docker.com/_/adminer)

