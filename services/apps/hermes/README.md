# Hermes profile credentials

The container hosts Hermes profiles. Pepper is the default profile at `/opt/data`; named profiles live at `/opt/data/profiles/<name>`. Each profile keeps its own model keys, bot tokens, integration credentials, and access lists in its own `.env`. Compose only supplies settings shared by the container, such as the dashboard and ports.

## Pepper cutover

Complete this before deploying the accompanying Compose change. The existing `services/apps/hermes/.env` holds the `HERMES_*` source values. Copy them into `storage/hermes/data/.env` under the names Hermes reads:

| Existing lab variable | Default profile variable |
|---|---|
| `HERMES_OPENAI_API_KEY` | `OPENAI_API_KEY` and `VOICE_TOOLS_OPENAI_KEY` |
| `HERMES_TELEGRAM_BOT_TOKEN` | `TELEGRAM_BOT_TOKEN` |
| `HERMES_TELEGRAM_ALLOWED_USERS` | `TELEGRAM_ALLOWED_USERS` |
| `HERMES_DISCORD_BOT_TOKEN` | `DISCORD_BOT_TOKEN` |
| `HERMES_DISCORD_ALLOWED_USERS` | `DISCORD_ALLOWED_USERS` |
| `HERMES_DISCORD_ALLOW_ANY_ATTACHMENT` | `DISCORD_ALLOW_ANY_ATTACHMENT` |
| `HERMES_PEPPER_GITHUB_APP_ID` | `GITHUB_APP_ID` |
| `HERMES_PEPPER_GITHUB_APP_INSTALLATION_ID` | `GITHUB_APP_INSTALLATION_ID` |
| — | `GITHUB_APP_PRIVATE_KEY_PATH=/opt/data/github-app.pem` |
| `HERMES_PEPPER_FAM_USERNAME` | `FAM_USERNAME` |
| `HERMES_PEPPER_FAM_PASSWORD` | `FAM_PASSWORD` |

Keep the existing `MODAL_TOKEN_ID`, `MODAL_TOKEN_SECRET`, and other Pepper settings in that file. The GitHub App private key remains mounted at `/opt/data/github-app.pem` for Pepper. Keep the profile `.env` readable only by the Hermes user. Do not use Compose `env_file` for profile credentials: that would put the same values back into every profile's process environment.

After the profile file is populated, recreate the Hermes container with this Compose definition and check Pepper's model, Telegram, Discord, and integrations. Then remove the unused Pepper variables from `services/apps/hermes/.env`; keep the three `HERMES_DASHBOARD_BASIC_AUTH_*` values and port settings there.

## Adding Mint later

Create Mint as a blank profile at `/opt/data/profiles/mint`, with her own `.env`, model configuration, and Modal token pair. Set `terminal.backend: modal` before enabling her bots: Compose disables Hermes' container file-write guard for Pepper's Modal backend, and that setting applies to the whole container. Create separate Telegram and Discord bots and give Mint their tokens and her own allowed-user lists. Do not copy Pepper's `.env`, `SOUL.md`, memory, or credential files. Check that Mint's OpenAI key, Modal token pair, and both bot tokens differ from Pepper's before starting her bots. Hermes blocks duplicate bot tokens; it does not check whether model or Modal keys are shared.

The current default gateway is configured with `gateway.multiplex_profiles: false`. Once Mint exists and both profiles have their own credentials, migrate the gateway explicitly with `hermes gateway migrate --multiplex` so one gateway serves both bots. This PR only prepares the container credential boundary; it does not change the live gateway.

Profile scoping prevents Hermes from automatically selecting Pepper's credentials for Mint. It is not a filesystem security boundary: both agents still share one container and its mounted `/opt/data` tree. If Mint must be unable to read Pepper's stored files even through tool access, run her in a separate container with a separate data volume and credential mounts.
