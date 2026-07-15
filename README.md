# 🏠

> A personal homelab running on a single laptop — infrastructure and applications managed entirely as code, secured by design, and built for reliability without the overhead of a data center.

## Architecture

<img width="1611" height="644" alt="Lab Architecture Diagram" src="https://github.com/user-attachments/assets/d9f92502-9b10-4588-8603-305a21ccff7e" />

### Access flows

| Path | Description |
|---|---|
| **Internet** | Users access services through Cloudflare. Cloudflare checks the user's email and sends a one-time code to verify them. Once verified, traffic goes through the tunnel into the server, where NGINX sends each request to the right service. |
| **Tailscale** | Devices connected to the Tailscale network can access services directly with randomized ports. The server only allows certain ports for laptops and phones, and shared users can only reach some services. |


## Philosophy

This project is built around a few core principles:

**Infrastructure as Code.**  
Everything that can be codified, is. Terraform manages DNS, tunnels, access policies, and network ACLs. Docker Compose files define every service with explicit configuration and resource limits. There are no SSH-and-pray moments.

**Defense in depth.**  
Default service ports are never used — every port is randomized. Tailscale provides a zero-trust overlay network with ACL-enforced access control. Cloudflare Tunnel fronts all public traffic, with Cloudflare Access requiring email-based authentication before any request reaches the server. The result is multiple independent layers of security.

**Segregation of concerns.**  
Services are split into two categories: **infrastructure** (what keeps the server running and observable) and **applications** (what makes the server useful). This separation makes it clear which services are foundational and which are the actual tools being hosted.

**Explicit resource governance.**  
Every single container has CPU and memory limits. No service can spike and starve another. The lab stays predictable under load.

## Services

### Infrastructure

|  | Service | Used for |
|---|---|---|
| ☁️ | [cloudflared](services/infra/cloudflared/) | Connects the server to Cloudflare's edge network, routing public traffic through a secure tunnel so services are accessible without exposing the server directly |
| 🔀 | [nginx](services/infra/nginx/) | Acts as a reverse proxy, reading the incoming domain and forwarding each request to the correct internal service |
| 📋 | [dozzle](services/infra/dozzle/) | Streams live logs from every running container into a browser dashboard for debugging and monitoring |
| 📊 | [btop](services/infra/btop/) | Exposes a real-time system monitor through the browser so you can check CPU, memory, and processes without SSH |
| 📁 | [filebrowser](services/infra/filebrowser/) | Provides a web-based file manager to browse, upload, and edit files across the entire server |
| ⏰ | [ofelia](services/infra/ofelia/) | Runs scheduled jobs inside containers using Docker labels, used here to trigger backups automatically |
| 💾 | [rclone](services/infra/rclone/) | Runs as a REST server that receives and stores backup data from Restic |
| 🔒 | [restic](services/infra/restic/) | Backs up Satisfactory game data to the Rclone server every 20 minutes, keeping saves safe from corruption or crashes |

### Applications

|  | Service | Used for |
|---|---|---|
| 🎮 | [satisfactory](services/apps/satisfactory/) | Runs a dedicated Satisfactory game server that friends can join at any time, with automatic backups and configurable player limits |
| 📹 | [ytdlp](services/apps/ytdlp/) | Provides a web interface for yt-dlp to download videos from various platforms directly to the server |
| 📖 | [kamiyomu](services/apps/kamiyomu/) | Runs a self-hosted, extensible manga reader that discovers, downloads, and organizes manga from various sources into a personal library |


### Template

```
services/
└── {infra|apps}/
    └── <service-name>/
        ├── configuration/        # Static config files mounted into the container
        ├── .env                  # Local environment values (gitignored)
        ├── .env.example          # Documented variables with placeholder values
        └── compose.yml           # Service definition with ports, volumes, networks, resources
```

### Policies

#### Keep configuration in a dedicated folder

Every service that needs static config files places them in a configuration subdirectory. This keeps mounts predictable and organized, with a single place to look for a service's settings.

```yaml
# services/infra/nginx/compose.yml

volumes:
  - ./configuration/nginx.conf.template:/etc/nginx/templates/nginx.conf.template:ro
```

#### Prefix environment variables with the service name

Variables are prefixed with the service name to avoid collisions and make it clear what each one controls.

```bash
# services/apps/satisfactory/.env.example

SATISFACTORY_MAX_PLAYERS=4
SATISFACTORY_GAME_PORT=7328
SATISFACTORY_MESSAGING_PORT=1273
```

#### Separate infra from apps

Infrastructure services handle monitoring, networking, and backups. Application services are the actual tools being hosted. This split keeps concerns clean — you know what keeps the server running versus what makes it useful.

```
services/
├── infra/       # monitoring, networking, backups, access
│   ├── btop/
│   ├── cloudflared/
│   ├── dozzle/
│   ├── nginx/
│   ├── ofelia/
│   ├── rclone/
│   └── restic/
└── apps/        # user-facing tools
    ├── satisfactory/
    └── ytdlp/
```

#### Set resource limits on every container

Every service declares how much CPU and memory it can use. This prevents any single service from spiking and starving the others, keeping the whole lab stable under load.

```yaml
# services/infra/dozzle/compose.yml

deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 64M
```

#### Use environment variables for port randomization

No service uses its default port. Every exposed port is set through an environment variable, making it easy to change and harder for automated scans to find services. Internal ports stay at their well-known defaults; only the externally-facing port is randomized.

```yaml
# services/infra/btop/compose.yml

ports:
  - "${BTOP_PORT}:7681"
```

#### Connect every service to the same network

All services join a shared Docker network so they can resolve each other by container name without complex networking setup.

```yaml
# shared pattern across all compose.yml files

networks:
  lab:
    name: lab
    external: true
```

#### Container conventions

Every container uses restart policies so services recover from crashes or host reboots without manual intervention. Container names are set explicitly to match their Compose service key, keeping references unambiguous across the stack.

```yaml
# shared pattern across all compose.yml files

restart: unless-stopped
container_name: <service-name>
```

## Getting started

### Prerequisites

- [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/)
- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.0
- A [Cloudflare](https://www.cloudflare.com/) account with a zone configured
- A [Tailscale](https://tailscale.com/) tailnet with devices enrolled

### Setup

```bash
# 1. Create the shared Docker network
make setup

# 2. Bootstrap Terraform
make terraform-init

# 3. Review and apply infrastructure changes
make terraform-plan
make terraform-apply

# 4. Start infrastructure services
make infra-up

# 5. Start application services
make apps-up
```

## Commands

| Command | Description |
|---|---|
| `setup` | Create the `lab` Docker network |
| `infra-up` | Start all infrastructure services |
| `infra-up-build` | Start infra services with rebuild |
| `infra-down` | Stop all infrastructure services |
| `apps-up` | Start all application services |
| `apps-up-build` | Start app services with rebuild |
| `apps-down` | Stop all application services |
| `terraform-init` | Initialize Terraform |
| `terraform-init-upgrade` | Re-initialize with provider upgrades |
| `terraform-plan` | Preview infrastructure changes |
| `terraform-apply` | Apply infrastructure changes |


## License

[MIT](LICENSE.md) — free to use, modify, and distribute as you see fit.
