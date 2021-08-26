.PHONY: help test

# Docker image name and tag
IMAGE:=syoh/my-jupyter-stack
TAG?=latest
# Shell that make should use
SHELL:=bash

# Enable BuildKit for Docker build
export DOCKER_BUILDKIT:=1



# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z0-9_%/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'



build: DARGS?=
build: ## Make the latest build of the image
	docker build $(DARGS) --rm --force-rm -t $(IMAGE):$(TAG) .



dev: ARGS?=
dev: DARGS?=
dev: PORT?=8888
dev: ## Make a container from a tagged image image
	docker run -it --rm -p $(PORT):8888 $(DARGS) $(IMAGE):$(TAG) $(ARGS)



run: DARGS?=
run: ## run a shell in interactive mode in a stack
	docker run -it --rm $(DARGS) $(IMAGE):$(TAG) $(SHELL)



test: ## Make a test run against the latest image
	pytest tests



test-env: ## Make a test environment by installing test dependencies with pip
	pip install -r tests/requirements.txt



dev-env: ## install libraries required to build the image and run tests
	pip install -r requirements-dev.txt


setup:
	./setup.sh



start: ARGS?=-d
start: PORT?=443
start: 
	PORT=$(PORT) docker-compose up $(ARGS)



colab: ARGS?=-d
colab: OPT?="\
	--NotebookApp.port_retries=0 \
	--NotebookApp.token='' \
	--NotebookApp.allow_origin='https://colab.research.google.com'"
colab: 
	PORT=8888 PASSWD="" OPT=$(OPT) docker-compose up $(ARGS)



stop: ARGS?=
stop: ## Stop container with docker-compose.yml
	docker-compose down $(ARGS)
