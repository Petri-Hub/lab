install:
	$(MAKE) install-pipx
	$(MAKE) install-pre-commit

setup:
	$(MAKE) setup-docker-networks

infra-up:
	docker compose -f services/infra/compose.yml up -d

infra-up-build:
	docker compose -f services/infra/compose.yml up -d --build

infra-down:
	docker compose -f services/infra/compose.yml down

apps-up:
	docker compose -f services/apps/compose.yml up -d

apps-up-build:
	docker compose -f services/apps/compose.yml up -d 0-

apps-down:
	docker compose -f services/apps/compose.yml down

terraform-init:
	terraform -chdir=terraform init

terraform-init-upgrade:
	terraform -chdir=terraform init -upgrade

terraform-plan:
	terraform -chdir=terraform plan

terraform-apply:
	terraform -chdir=terraform apply

install-pipx:
	sudo apt-get install -y pipx

install-pre-commit:
	pipx install pre-commit && pre-commit install

setup-docker-networks:
	docker network create lab
