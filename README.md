# 🏠

> My self-hosted infrastructure and application platform — running on a single server, managed as code, and designed with security, reliability, and minimal operational overhead in mind.

## Architecture

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

| Service | Description |
|---|---|
| [cloudflared](services/infra/cloudflared/) | Cloudflare Tunnel client |
| [nginx](services/infra/nginx/) | Reverse proxy with env-substituted config |
| [dozzle](services/infra/dozzle/) | Real-time Docker log viewer |
| [btop](services/infra/btop/) | Browser-accessible system monitor via ttyd+tmux |
| [filebrowser](services/infra/filebrowser/) | Web-based file manager |
| [ofelia](services/infra/ofelia/) | Docker-native cron scheduler |
| [rclone](services/infra/rclone/) | Rclone REST daemon (backup backend) |
| [restic](services/infra/restic/) | Restic backup client (Satisfactory data) |

### Applications

| Service | Description |
|---|---|
| [satisfactory](services/apps/satisfactory/) | Dedicated Satisfactory game server |
| [ytdlp](services/apps/ytdlp/) | Web UI for yt-dlp video downloads |


## Template

```
services/
└── {infra|apps}/
    └── <service-name>/
        ├── configuration/        # Static config files mounted into the container
        ├── .env                  # Local environment values (gitignored)
        ├── .env.example          # Documented variables with placeholder values
        └── compose.yml           # Service definition with ports, volumes, networks, resources
```

## Policies

### Keep configuration in a dedicated folder

Every service that needs static config files places them in a configuration subdirectory. This keeps mounts predictable and organized, with a single place to look for a service's settings.

```yaml
# services/infra/nginx/compose.yml

volumes:
  - ./configuration/nginx.conf.template:/etc/nginx/templates/nginx.conf.template:ro
```

### Prefix environment variables with the service name

Variables are prefixed with the service name to avoid collisions and make it clear what each one controls.

```bash
# services/apps/satisfactory/.env.example

SATISFACTORY_MAX_PLAYERS=4
SATISFACTORY_GAME_PORT=7328
SATISFACTORY_MESSAGING_PORT=1273
```

### Separate infra from apps

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

### Set resource limits on every container

Every service declares how much CPU and memory it can use. This prevents any single service from spiking and starving the others, keeping the whole lab stable under load.

```yaml
# services/infra/dozzle/compose.yml

deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 64M
```

### Use environment variables for port randomization

No service uses its default port. Every exposed port is set through an environment variable, making it easy to change and harder for automated scans to find services.

```yaml
# services/infra/btop/compose.yml

ports:
  - "${BTOP_PORT}:7681"
```

### Connect every service to the same network

All services join a shared Docker network so they can resolve each other by container name without complex networking setup.

```yaml
# shared pattern across all compose.yml files

networks:
  lab:
    name: lab
    external: true
```

## Backups

Satisfactory game data is automatically backed up every 20 minutes using the Restic + Rclone pipeline:

1. **Ofelia** (label-based cron scheduler) triggers the backup job.
2. **Restic** reads the Satisfactory config directory (`/data`) and runs `restic backup`.
3. **Rclone** serves as a REST server backend, storing backups locally.

This ensures that even in a game server crash or data corruption scenario, the maximum data loss window is 20 minutes.


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

See the [Makefile](Makefile) for all available commands and the [terraform](terraform/) directory for infrastructure configuration. Service-specific environment variables are documented in each service's `.env.example` file under [services](services/).

## Makefile reference

| Target | Description |
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


## Repository structure

```
lab/
├── docker/                  # Custom Dockerfile builds
│   └── btop/               # Browser-accessible system monitor
├── services/                # Docker Compose service definitions
│   ├── infra/               # Infrastructure services
│   │   ├── btop/
│   │   ├── cloudflared/
│   │   ├── dozzle/
│   │   ├── filebrowser/
│   │   ├── nginx/
│   │   ├── ofelia/
│   │   ├── rclone/
│   │   └── restic/
│   └── apps/                # Application services
│       ├── satisfactory/
│       └── ytdlp/
├── terraform/               # Infrastructure as Code
│   ├── cloudflare/          # Cloudflare tunnel, DNS, Access
│   └── tailscale/           # Device tags and ACLs
├── storage/                 # Persistent data (gitignored)
├── Makefile
└── .gitignore
```
