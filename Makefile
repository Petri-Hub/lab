infra-up:
	docker compose -f services/infra/compose.yml up -d

infra-down:
	docker compose -f services/infra/compose.yml down

apps-up:
	docker compose -f services/apps/compose.yml up -d

apps-down:
	docker compose -f services/apps/compose.yml down