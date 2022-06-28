.PHONY: build build-sa-enabled run all all-sa-enabled clean-build

Nothing:
	@echo -n "Provide an argument [build, build-sa-enabled, run, all, all-sa-enabled, clean-build]"

build: 
	docker build -t vault-abe .

build-sa-enabled:
	docker build --build-arg sa_enabled=true -t vault-abe .

run:
	docker-compose -f other/docker/docker-compose.yml up --build --remove-orphans

all: clean-build build run

all-sa-enabled: clean-build build-sa-enabled run

clean-build: 
	sudo rm -rf ./other/docker/vault/config/build ./other/docker/vault/config/vault_data ./other/docker/vault/config/vault_operator_secrets.json
