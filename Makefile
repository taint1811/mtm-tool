# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= make.d/config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= make.d/deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# grep the version from the mix file
VERSION=1.0.0

# DOCKER TASKS
# Build the container
build: ## Build compose the container for dev
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1  docker-compose -f docker-compose.yml -f docker-compose.override.yml build
build-nc: ## Build compose the container for dev
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1  docker-compose -f docker-compose.yml -f docker-compose.override.yml build --no-cache
build-prod: ## Build compose the container for prod
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1  docker-compose -f docker-compose.yml -f docker-compose.prod.yml build
build-prod-nc: ## Build compose the container for prod
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1  docker-compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache

up: ## Run container compose for dev
	docker-compose -f docker-compose.yml -f docker-compose.override.yml up
up-d: ## Run container compose for dev detach
	docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

up-prod: ## Run container compose for prod
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
up-prod-d: ## Run container compose for prod detach
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

up-mutagen:
	docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
	mutagen project start
stop-mutagen:
	docker ps --filter name=maydungcu* --filter status=running -aq | xargs docker stop
	mutagen project terminate
stop-sync:
	docker-sync stop
	docker-sync clean
	docker ps --filter name=maydungcu* --filter status=running -aq | xargs docker stop
up-sync:
	#docker-sync start
	#fswatch fix gulp watch file
	docker-sync start
	docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
re-sync:
	docker-sync stop && docker-sync clean && docker-sync start

version: ## Output the current version
	@echo $(VERSION)