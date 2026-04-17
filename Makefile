COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/kkraft/data

all: build

build:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	docker-compose -f $(COMPOSE_FILE) up -d --build

down:
	docker-compose -f $(COMPOSE_FILE) down

clean:
	docker-compose -f $(COMPOSE_FILE) down -v

fclean: clean
	docker system prune -a --volumes -f
	sudo rm -rf $(DATA_DIR)/mariadb/*
	sudo rm -rf $(DATA_DIR)/wordpress/*

re: fclean all

.PHONY: all build down clean fclean re