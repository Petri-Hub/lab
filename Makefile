setup:
	docker network create lab

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
