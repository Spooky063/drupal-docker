dc := docker-compose
dr := $(dc) run --rm
de := $(dc) exec

help_fun := \
    %help; \
    while(<>) { \
        if(/^([a-z0-9_-]+):.*\#\#(?:@(\w+))?\s(.*)$$/) { \
            push(@{$$help{$$2 // 'options'}}, [$$1, $$3]); \
        } \
    }; \
    print "usage: make [target]\n\n"; \
    for ( sort keys %help ) { \
        print "$$_:\n"; \
        printf("\033[36m  %-20s %s\033[0m\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
        print "\n"; \
    }

.PHONY: help
help: ## Affiche l'aide
	@perl -e '$(help_fun)' $(MAKEFILE_LIST)

.PHONY: build
build: ## Build les services
	DRUPAL_VERSION=8.x STABILITY=dev $(dc) up --build

.PHONY: dev
dev: ## Lance le serveur de développement
	$(dc) up

.PHONY: drop-tables
drop-tables: ## Supprime toutes les tables de la base de données -- DB_DATABASE=database
	$(de) -T mariadb /usr/bin/mysqldump -u root -proot --add-drop-table --no-data $(DB_DATABASE) | \
	grep -e '^DROP \| FOREIGN_KEY_CHECKS' | \
	$(de) -T mariadb /usr/bin/mysql -u root -proot $(DB_DATABASE)

.PHONY: install
install: ## Installation globale du site (utilisé préalablement drop-tables)
	$(dr) php install/install.sh

.PHONY: admin
admin: ## Installation du drupal
	$(de) php vendor/bin/drush si standard --account-name=admin --account-pass=admin --locale=fr -y

.PHONY: preprocess
preprocess: ## Enlève la concaténation du JS/CSS
	$(de) php vendor/bin/drush cset system.performance css.preprocess 0 -y
	$(de) php vendor/bin/drush cset system.performance js.preprocess 0 -y

.PHONY: clear-cache
clear-cache: ## Vide le cache Drupal
	$(de) php vendor/bin/drush cr

preprocess-cache: preprocess clear-cache ## Enlève la concaténation du JS/CSS et vide le cache

.PHONY: config-export
config-export:
	$(de) php vendor/bin/drush cex -y

.PHONY: permission
permission: ## Recréer les permission du répertoire
	$(de) php chown -R $(shell id -u):$(shell id -g) .
