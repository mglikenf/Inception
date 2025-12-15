COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = $(HOME)/data
WORDPRESS_DIR = $(DATA_DIR)/wordpress
MARIADB_DIR = $(DATA_DIR)/mariadb

.PHONY: all build up down clean fclean re logs ps status help setup

# Default target
all: setup build up

# Create necessary volume directories
setup:
	@echo "Creating data directories..."
	@mkdir -p $(WORDPRESS_DIR)
	@mkdir -p $(MARIADB_DIR)
	@echo "Directories created"

# Build images
Build:
	@echo "Building Docker images..."
	docker compose -f $(COMPOSE_FILE) build --no-cache
	@echo "Build complete"

# Setup containers
up: setup
	@echo "Starting containers..."
	docker compose -f $(COMPOSE_FILE) up -d
	@echo "Containers started"
	@$(MAKE) ps

# Stop containers
down:
	@echo "Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down
	@echo "Containers stopped"

# Clean: stop containers and remove volumes
clean: down
	@echo "Removing volumes..."
	docker compose -f $(COMPOSE_FILE) down -v
	@echo "Volumes removed"

# Full clean: remove everything including data directories
fclean: clean
	@echo "Removing data directories..."
	@sudo rm -rf $(DATA_DIR)
	@echo "Removing Docker images..."
	docker compose -f $(COMPOSE_FILE) down -v --rmi all
	@echo "Full cleanup complete"

# Rebuild everything from scratch
re: fclean all

# Show logs
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

# Show container status
ps:
	@docker compose -f $(COMPOSE_FILE) ps
