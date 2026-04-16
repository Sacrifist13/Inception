COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/kkraft/data

all: build

build:
	@echo "Création des dossiers de données sur la machine hôte..."
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@echo "Lancement de docker-compose..."
	docker-compose -f $(COMPOSE_FILE) up -d --build

down:
	@echo "Arrêt des conteneurs..."
	docker-compose -f $(COMPOSE_FILE) down

clean:
	@echo "Suppression des conteneurs, réseaux et volumes Docker..."
	docker-compose -f $(COMPOSE_FILE) down -v

fclean: clean
	@echo "Nettoyage profond du système Docker..."
	docker system prune -a --volumes -f
	@echo "Suppression des fichiers de données locaux..."
	sudo rm -rf $(DATA_DIR)/mariadb/*
	sudo rm -rf $(DATA_DIR)/wordpress/*

re: fclean all

.PHONY: all build down clean fclean re