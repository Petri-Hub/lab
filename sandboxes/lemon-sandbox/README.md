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

For Roblox Assets MCP, set `LEMON_ROBLOX_ASSETS_API_KEY` in the same ignored `.env` from the key stored in 1Password. It is optional for starting the sandbox, but required by the MCP. Compose passes it as `ROBLOX_API_KEY`, and the sandbox exposes it to SSH sessions through PAM. The key must grant the access required for Creator Store and Asset Delivery. The installed MCP release does not upload assets. Credentials are available to commands in this sandbox, so use a suitably scoped key.

Hermes must trust the sandbox's persistent SSH host key before starting the MCP over SSH. From a trusted lab host, obtain `storage/lemon-sandbox/ssh-host-keys/ssh_host_ed25519_key.pub`, verify its fingerprint, and add its public key to Lemon's Hermes `known_hosts` file with `lemon-sandbox` as the hostname. Preserve existing entries. The private host key must stay on the lab host. See Pepper's Lemon configuration for the SSH command and the `known_hosts` path. A changed host key requires verifying the replacement before updating that entry.

## Studio previews

Rojo Share uses Cloudflare Quick Tunnels to connect collaborators' Studio sessions to a project. The sandbox image provides `cloudflared`; each project pins Rojo and Rojo Share through Rokit.
