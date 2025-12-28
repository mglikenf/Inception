ENV_SRC = $(HOME)/.inception_config/.env
ENV_DEST = srcs/.env
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = $(HOME)/data
WORDPRESS_DIR = $(DATA_DIR)/wordpress
MARIADB_DIR = $(DATA_DIR)/mariadb
REDIS_DIR = $(DATA_DIR)/redis
STATIC_DIR = $(DATA_DIR)/static

GREEN = \033[0;32m
RED = \033[0;31m
RESET = \033[0m

.PHONY: all build up down clean fclean re logs ps status help setup check-env

# Default target
all: check-env setup build up

# Copy environment variables config file to project
check-env:
	@echo "Checking environment configuration..."
	@if [ ! -f $(ENV_SRC) ]; then \
		echo "$(RED)Error: Source environment file not found at $(ENV_SRC)$(RESET)"; \
		echo "Please create ~/.inception_config/.env first"; \
		exit 1; \
	fi
	@if [ ! -s $(ENV_SRC) ]; then \
		echo "$(RED)Error: Source file is empty$(RESET)"; \
		exit 1; \
	fi
	@cp -f $(ENV_SRC) $(ENV_DEST)
	@echo "$(GREEN)Environment ready$(RESET)"

# Create necessary volume directories
setup:
	@echo "Creating data directories..."
	@mkdir -p $(WORDPRESS_DIR)
	@mkdir -p $(MARIADB_DIR)
	@mkdir -p $(REDIS_DIR)
	@mkdir -p $(STATIC_DIR)
	@echo "$(GREEN)Directories created$(RESET)"

# Build images
build:
	@echo "Building Docker images..."
	docker compose -f $(COMPOSE_FILE) build --no-cache
	@echo "$(GREEN)Build complete$(RESET)"

# Setup containers
up: setup
	@echo "Starting containers..."
	docker compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)Containers started$(RESET)"
	@$(MAKE) ps

# Stop containers
down:
	@echo "Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)Containers stopped$(RESET)"

# Clean: stop containers and remove volumes
clean: down
	@echo "Removing volumes..."
	docker compose -f $(COMPOSE_FILE) down -v
	@echo "$(GREEN)Volumes removed$(RESET)"

# Full clean: remove everything including data directories
fclean: clean
	@echo "Removing data directories..."
	@sudo rm -rf $(DATA_DIR)
	@echo "Removing Docker images..."
	docker compose -f $(COMPOSE_FILE) down -v --rmi all
	@echo "$(GREEN)Full cleanup complete$(RESET)"
	@rm -f $(ENV_DEST)

# Rebuild everything from scratch
re: fclean all

# Show logs
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

# Show container status
ps:
	@docker compose -f $(COMPOSE_FILE) ps
