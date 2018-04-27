.PHONY: example

.env:
	echo "DEV_UID=$(shell id -u)\nDEV_GID=$(shell id -g)" > .env

example: .env
	docker-compose -f example.docker-compose.yml run --rm app bash
