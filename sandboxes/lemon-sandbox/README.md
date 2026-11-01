# Lemon sandbox

This service runs Lemon's SSH development container on the `lab` Docker network. Its workspace holds multiple Roblox repositories under `/home/lemon/workspace/<repository>`. The image comes from the [pepper repository](https://github.com/Petri-Hub/pepper); each checkout installs its own tool versions with Rokit.

## Prepare storage and SSH access

From the lab repository root, create the directories and install Lemon's SSH **public** key before starting the service:

```bash
install -d -m 0755 storage/lemon-sandbox/workspace
install -d -m 0700 storage/lemon-sandbox/ssh-host-keys
install -m 0600 /path/to/lemon-ssh-public-key.pub storage/lemon-sandbox/authorized_keys
cp sandboxes/lemon-sandbox/.env.example sandboxes/lemon-sandbox/.env
make sandboxes-up
```

The workspace directory must be writable by UID 1000, the `lemon` user in the image. The container creates its SSH host key in `ssh-host-keys` on first start and reuses it after container replacement. Keep Lemon's matching SSH **private** key in 1Password and supply it to his Hermes profile when the terminal backend is connected; it does not belong in this repository or image.

Hermes will reach `lemon-sandbox:22` on the Docker network. The service publishes no host port. Starting it does not yet change Lemon's Hermes toolset or connect his terminal; those are separate steps.

The `.env` file selects the image tag and the timezone the container runs in, so the commits Lemon writes and the files Rojo builds carry the lab's local time. `latest` follows the publishing workflow; a commit tag holds a specific version. The image must be published and readable by the lab before `make sandboxes-up` can pull it.

The `storage/lemon-sandbox` directory is also what the `restic-lemon-sandbox` job in `services/infra/restic/` snapshots every six hours, so uncommitted work survives losing the host. The toolchain output each project regenerates from its own manifest stays out of the snapshot.

A checkout does not hold the Open Cloud key its tests need. The key is created in Roblox, kept in 1Password, and set in this service's ignored `.env`; compose passes it to the container as `JEST_ROBLOX_*`, the names the project's Makefile exports. No repository carries a copy, and replacing the container keeps the credentials.

## Enable zrok

The image includes `zrok2`. Its enabled environment lives in the `lemon_zrok_state` Docker volume, mounted at `/home/lemon/.zrok2`. This keeps the account token out of the image, Compose files and workspace backups. The volume survives container replacement; if it is deleted, enable the environment again.

From the lab repository root, pull the updated image and recreate `lemon-sandbox`:

```bash
docker compose -f sandboxes/compose.yml pull lemon-sandbox
docker compose -f sandboxes/compose.yml up -d --force-recreate lemon-sandbox
```

Then open a shell as Lemon and enter the account token from 1Password without placing it in shell history:

```bash
docker exec -it -u lemon lemon-sandbox bash
read -rsp 'zrok account token: ' ZROK_TOKEN; echo
zrok2 enable "$ZROK_TOKEN"
unset ZROK_TOKEN
zrok2 status
```

`zrok2 status` should show `Account Token` and `EnvZId` as `<<SET>>`. The zrok environment is enabled once per volume; starting Rojo and opening a share are later, per-session actions.
