install:
	$(MAKE) install-pipx
	$(MAKE) install-pre-commit
	
setup:
	$(MAKE) setup-docker-networks

system-cpu-performatic:
	echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

system-cpu-powersave:
	echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

check-cpu-governor:
	cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
	
infra-up:
	docker compose -f services/infra/compose.yml up -d

infra-up-build:
	docker compose -f services/infra/compose.yml up -d --build

infra-down:
	docker compose -f services/infra/compose.yml down

apps-up:
	$(MAKE) system-cpu-performatic
	docker compose -f services/apps/compose.yml up -d

apps-down:
	$(MAKE) system-cpu-powersave
	docker compose -f services/apps/compose.yml down

apps-up-build:
	docker compose -f services/apps/compose.yml up -d 0-

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

