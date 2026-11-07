# Wakapi agent reporters

Ofelia runs each agent's WakaTime sync every five minutes as UID and GID `10000`, matching the reporter container and its state files. Ofelia otherwise defaults to root, which can be blocked from opening the existing user's lock files in `/tmp` and silently skip the sync.

Each reporter mounts its agent's Hermes data read-only and keeps its own WakaTime state and API key. The README cards in the Pepper repository show Wakapi's counted time, which may not include AI app activity.

## Applying the reporter fix

If reporter logs were created by root, give those files back to the reporter user, then recreate the reporter containers so Ofelia reads the labels. Recreating Lemon's reporter also refreshes its profile bind mount. These steps interrupt reporting, but do not restart Hermes or Wakapi.

From the lab checkout on the host:

```sh
docker exec -u root wakapi-mint chown 10000:10000 /state/wakatime.log
docker exec -u root wakapi-lemon chown 10000:10000 /state/wakatime.log
docker compose -p apps -f services/apps/compose.yml up -d --no-deps --force-recreate wakapi-pepper wakapi-mint
docker compose -p wakapi -f services/apps/wakapi/compose.yml up -d --no-deps --force-recreate wakapi-lemon
docker restart ofelia
```

The project names above match the current lab deployment; check the containers' `com.docker.compose.project` labels if those change. The running Ofelia version needs a restart to load the new labels; this briefly interrupts its scheduled jobs. Afterward, check that Lemon's `/hermes` mount contains the current profile and that Ofelia picked up the user labels. Verify that recent activity reaches each Wakapi account; a successful Ofelia job alone does not prove a sync succeeded. WakaTime's SQLite parser has a five-second budget per run and can log timeouts while its saved cursor works through older messages. Check that the cursor advances and that file-level activity reaches Wakapi before expecting language totals in Pepper's README. Older activity depends on what Hermes retained and what the sync can parse.
