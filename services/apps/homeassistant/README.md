# Home Assistant

Runs Home Assistant in Container mode: one container, no Supervisor and no add-ons. It is the hub behind Mint's voice at home. Ava, on a phone, is the microphone and speaker. Home Assistant's Assist pipeline turns speech into text, hands it to Mint through the Hermes Voice integration, and speaks the answer. Speech-to-text and text-to-speech use OpenAI, so no speech containers run here.

```
Redmi (Ava) <-- ESPHome API, Tailscale --> homeassistant --> hermes:8642/p/mint/v1
```

- The container joins the `lab` network, so Hermes reaches it as `homeassistant:8123` and Home Assistant reaches Mint without leaving Docker.
- The web UI is published on `HOMEASSISTANT_PORT` and reached over Tailscale. There is no Cloudflare route and no public endpoint.
- The Redmi is tagged `assistant` in Terraform. Home Assistant connects out to it on the ESPHome port; the phone does not need to reach the lab. Bridge networking has no mDNS, so the phone is added by its Tailscale address.
- `configuration.yaml` is the seed, mounted read-only. Everything else is set in the UI and lives in `storage/homeassistant/config`.

## First run

From the lab checkout on the host:

```sh
cp services/apps/homeassistant/.env.example services/apps/homeassistant/.env   # then set a random port
docker compose -f services/apps/homeassistant/compose.yml up -d
```

Then in the web UI:

1. Create the owner account.
2. Create a user for Mint, with a long-lived token on that user's profile. The token goes in Mint's `.env` as `HASS_TOKEN`, never in this repository.
3. Install Hermes Voice from the Marketplace. Starting with Home Assistant 2026.11, HACS ships inside Home Assistant as the **Marketplace** (Settings > Marketplace), with the same catalog and repositories, so there is nothing to install. The old HACS custom integration cannot be installed on 2026.11 or newer: Home Assistant removes it on startup. Add `https://github.com/majorminorlabs/hermes-voice` as a custom repository of type Integration, download it, and restart Home Assistant. It lands in `/config/custom_components`, which the backup carries.
4. Add the OpenAI integration with its own API key, and build an Assist pipeline: OpenAI speech-to-text, Hermes Voice as the conversation agent, OpenAI text-to-speech. Point Hermes Voice at `http://hermes:8642/p/mint/v1` with Mint's `API_SERVER_KEY`.
5. Add the Redmi through the ESPHome integration, using its Tailscale address and the port in `infra_esphome_port`.

Restarting `homeassistant` interrupts the voice device only. Recreating `hermes` for Mint's settings is a separate step and restarts Mint.

## Backups

`restic-homeassistant` backs up the config folder every six hours, without the history database, logs and caches. The database is a week of history and is not worth keeping.
