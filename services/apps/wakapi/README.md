# Wakapi agent reporters

Ofelia runs each agent's WakaTime sync every five minutes as UID and GID `10000`, matching the reporter container and its state files. Ofelia otherwise defaults to root, which can be blocked from opening the existing user's lock files in `/tmp` and silently skip the sync.

Each reporter mounts its agent's Hermes data read-only and keeps its own WakaTime state and API key. The README cards in the Pepper repository show Wakapi's counted time, which may not include AI app activity.

## Applying the reporter fix

The existing Mint and Lemon reporter logs were created by root. Before applying this change, give those two files back to the reporter user, then recreate the three reporter containers so Ofelia reads the new labels. Recreating Lemon's reporter also refreshes its stale profile bind mount. These steps interrupt reporting, but do not restart Hermes or Wakapi.

From the lab checkout on the host:

```sh
docker exec -u root wakapi-mint chown 10000:10000 /state/wakatime.log
docker exec -u root wakapi-lemon chown 10000:10000 /state/wakatime.log
docker compose -f services/apps/wakapi/compose.yml up -d --no-deps --force-recreate wakapi-pepper wakapi-mint wakapi-lemon
```

Afterward, check that Lemon's `/hermes` mount contains the current profile, that Ofelia picked up the user labels, and that new reporter logs have no lock or parsing errors. Verify that recent activity reaches each Wakapi account; a successful Ofelia job alone does not prove a sync succeeded. Check whether file-level activity reaches Wakapi before expecting language totals in Pepper's README. Older activity depends on what Hermes retained and what the sync can parse.
