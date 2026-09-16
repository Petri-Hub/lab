<h1 align="center">🏠 lab</h1>

<br>

<h3 align="center">A homelab running on a single laptop.<br>Infrastructure and services managed entirely as code</h3>

<p align="center">
  <a href="https://github.com/Petri-Hub/lab/actions/workflows/terraform-validation.yml"><img alt="Terraform validation" src="https://img.shields.io/github/actions/workflow/status/Petri-Hub/lab/terraform-validation.yml?label=terraform&logo=terraform&logoColor=white" /></a> <a href="https://github.com/Petri-Hub/lab/commits/main"><img alt="Last commit" src="https://img.shields.io/github/last-commit/Petri-Hub/lab" /></a> <img alt="Time spent" src="https://img.shields.io/endpoint?url=https%3A%2F%2Flab-wakapi.petri.zip%2Fapi%2Fcompat%2Fshields%2Fv1%2FPetri%2Fproject%3Alab%2Finterval%3Aall_time&label=time%20spent&logo=wakatime&logoColor=white&color=blue&cacheSeconds=3600" />
</p>

<br>

## About

> **TL;DR:** the server that sits at home and runs my game servers, backups and a few tools I use every day. Terraform manages Cloudflare and Tailscale, Docker Compose manages every service, and nothing is reachable without going through one of the two.

## Hardware

<table>
  <tr><td><b>Machine</b></td><td>VAIO laptop (VJFE59F11X)</td></tr>
  <tr><td><b>CPU</b></td><td>AMD Ryzen 7 5700U, 8 cores / 16 threads</td></tr>
  <tr><td><b>Memory</b></td><td>16 GB</td></tr>
  <tr><td><b>Storage</b></td><td>512 GB NVMe SSD</td></tr>
  <tr><td><b>OS</b></td><td>Ubuntu 26.04 LTS</td></tr>
  <tr><td><b>Backups</b></td><td>16 GB USB flash drive, where Restic keeps the snapshots</td></tr>
</table>

> Limited hardware forces some creativity. Restic deduplicates every snapshot, so backups every 20 minutes still fit on a 16 GB flash drive, and services are picked for doing one thing well on little memory: most containers here use less than 64 MB.

## Architecture

<img width="1611" height="644" alt="Lab Architecture Diagram" src="https://github.com/user-attachments/assets/d9f92502-9b10-4588-8603-305a21ccff7e" />

### Access flows

| Path | Description |
|---|---|
| **Internet** | Users access services through Cloudflare. Cloudflare checks the user's email and sends a one-time code to verify them. Once verified, traffic goes through the tunnel into the server, where NGINX sends each request to the right service. A few specific paths skip the email check, like the Wakapi API that my GitHub profile reads from. |
| **Tailscale** | Devices connected to the Tailscale network can access services directly with randomized ports. The server only allows certain ports for laptops and phones, and shared users can only reach some services. |

## Philosophy

**Infrastructure as Code.**  
Everything that can be codified, is. Terraform manages DNS, the tunnel, access policies and network ACLs, and Docker Compose defines every service. There are no SSH-and-pray moments.

**Defense in depth.**  
Public traffic only enters through a Cloudflare Tunnel with Cloudflare Access in front of it, private traffic goes through Tailscale with ACLs, and no service listens on its default port. Each layer holds on its own.

**Predictable under load.**  
Services are split between infrastructure and applications, and every container runs with CPU and memory limits, so one service can't starve the others.

## Services

### Infrastructure

| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Service | Used for |
|:---:|---|---|
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/cloudflare.svg" width="20" height="20" alt="" /> | [cloudflared](services/infra/cloudflared/) | Connects the server to Cloudflare's edge network, routing public traffic through a secure tunnel so services are accessible without exposing the server directly |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/nginx.svg" width="20" height="20" alt="" /> | [nginx](services/infra/nginx/) | Acts as a reverse proxy, reading the incoming domain and forwarding each request to the correct internal service |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/dozzle.svg" width="20" height="20" alt="" /> | [dozzle](services/infra/dozzle/) | Streams live logs from every running container into a browser dashboard for debugging and monitoring |
| <img src="https://raw.githubusercontent.com/aristocratos/btop/HEAD/Img/icon.svg" width="20" height="20" alt="" /> | [btop](services/infra/btop/) | Exposes a real-time system monitor through the browser so you can check CPU, memory, and processes without SSH |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/filebrowser.png" width="20" height="20" alt="" /> | [filebrowser](services/infra/filebrowser/) | Provides a web-based file manager to browse, upload, and edit files across the entire server |
| <img src="https://raw.githubusercontent.com/mcuadros/ofelia/HEAD/static/avatar.png" width="20" height="20" alt="" /> | [ofelia](services/infra/ofelia/) | Runs scheduled jobs inside containers using Docker labels, used here to trigger backups automatically |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/rclone.svg" width="20" height="20" alt="" /> | [rclone](services/infra/rclone/) | Runs as a REST server that receives and stores backup data from Restic |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/restic.png" width="20" height="20" alt="" /> | [restic](services/infra/restic/) | Backs up the Satisfactory and Palworld saves and the Wakapi database to the Rclone server every 20 minutes |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/upsnap.svg" width="20" height="20" alt="" /> | [upsnap](services/infra/upsnap/) | Wakes my main PC with Wake-on-LAN, since it lives outside the lab, and shows which machines on the network are online |

### Applications

| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Service | Used for |
|:---:|---|---|
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/satisfactory.png" width="20" height="20" alt="" /> | [satisfactory](services/apps/satisfactory/) | Runs a dedicated Satisfactory game server that friends can join at any time, with automatic backups and configurable player limits |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/palworld.png" width="20" height="20" alt="" /> | [palworld](services/apps/palworld/) | Runs a dedicated Palworld server for friends, with its saves backed up automatically |
| <img src="https://shared.fastly.steamstatic.com/community_assets/images/apps/322330/a80aa6cff8eebc1cbc18c367d9ab063e1553b0ee.jpg" width="20" height="20" alt="" /> | [dst](services/apps/dst/) | Runs a Don't Starve Together dedicated server cluster (Master + Caves shards) that friends can join over Tailscale |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/teamspeak.svg" width="20" height="20" alt="" /> | [teamspeak](services/apps/teamspeak/) | Runs a self-hosted TeamSpeak 6 voice server so friends can join a private voice channel over Tailscale |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/wakapi.svg" width="20" height="20" alt="" /> | [wakapi](services/apps/wakapi/) | Collects coding activity from the editors and terminals on my machines, a self-hosted alternative to WakaTime that also feeds my GitHub profile |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/yt-dlp.svg" width="20" height="20" alt="" /> | [ytdlp](services/apps/ytdlp/) | Provides a web interface for yt-dlp to download videos from various platforms directly to the server |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/kamiyomu.svg" width="20" height="20" alt="" /> | [kamiyomu](services/apps/kamiyomu/) | Runs a self-hosted, extensible manga reader that discovers, downloads, and organizes manga from various sources into a personal library |
| <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/kavita.svg" width="20" height="20" alt="" /> | [kavita](services/apps/kavita/) | Serves a polished web-based reader over the manga KamiYomu downloads, with library management, metadata, and per-user reading progress |

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

Static config files live in a `configuration/` subdirectory, so there is a single place to look for a service's settings.

```yaml
# services/infra/nginx/compose.yml

volumes:
  - ./configuration/nginx.conf.template:/etc/nginx/templates/nginx.conf.template:ro
```

#### Prefix environment variables with the service name

Prefixes avoid collisions and make it clear what each variable controls.

```bash
# services/apps/satisfactory/.env.example

SATISFACTORY_MAX_PLAYERS=4
SATISFACTORY_GAME_PORT=7328
SATISFACTORY_MESSAGING_PORT=1273
```

#### Separate infra from apps

Infrastructure keeps the server running and observable; applications are what it is actually hosting.

```
services/
├── infra/       # monitoring, networking, backups, access
│   ├── btop/
│   ├── cloudflared/
│   ├── dozzle/
│   ├── filebrowser/
│   ├── nginx/
│   ├── ofelia/
│   ├── rclone/
│   ├── restic/
│   └── upsnap/
└── apps/        # game servers and tools
    ├── dst/
    ├── kamiyomu/
    ├── kavita/
    ├── palworld/
    ├── satisfactory/
    ├── teamspeak/
    ├── wakapi/
    └── ytdlp/
```

#### Set resource limits on every container

```yaml
# services/infra/dozzle/compose.yml

deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 64M
```

#### Use environment variables for port randomization

Only the port exposed on the host is randomized; internal ports stay at their well-known defaults.

```yaml
# services/infra/btop/compose.yml

ports:
  - "${BTOP_PORT}:7681"
```

#### Connect every service to the same network

Services resolve each other by container name on a shared Docker network. The exception is UpSnap, which needs the host network to send Wake-on-LAN packets.

```yaml
# shared pattern across all compose.yml files

networks:
  lab:
    name: lab
    external: true
```

#### Container conventions

Containers restart on their own after a crash or a reboot, and their names match the Compose service key.

```yaml
# shared pattern across all compose.yml files

restart: unless-stopped
container_name: <service-name>
```

## Technologies

<table align="center">
  <tr>
    <td align="center" width="96"><img src="https://cdn.simpleicons.org/ubuntu" width="48" height="48" alt="Ubuntu" /><br>Ubuntu</td>
    <td align="center" width="96"><img src="https://cdn.simpleicons.org/docker" width="48" height="48" alt="Docker" /><br>Docker</td>
    <td align="center" width="96"><img src="https://cdn.simpleicons.org/terraform" width="48" height="48" alt="Terraform" /><br>Terraform</td>
    <td align="center" width="96"><img src="https://cdn.simpleicons.org/cloudflare" width="48" height="48" alt="Cloudflare" /><br>Cloudflare</td>
    <td align="center" width="96"><img src="https://cdn.simpleicons.org/tailscale/9198A1" width="48" height="48" alt="Tailscale" /><br>Tailscale</td>
    <td align="center" width="96"><img src="https://cdn.simpleicons.org/nginx" width="48" height="48" alt="NGINX" /><br>NGINX</td>
    <td align="center" width="96"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/githubactions/githubactions-original.svg" width="48" height="48" alt="GitHub Actions" /><br>GitHub Actions</td>
  </tr>
</table>

## Getting started

### Prerequisites

- [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/)
- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.0
- A [Cloudflare](https://www.cloudflare.com/) account with a zone configured
- A [Tailscale](https://tailscale.com/) tailnet with devices enrolled

### Setup

```bash
# 1. Install the local tooling
make install

# 2. Create the shared Docker network
make setup

# 3. Bootstrap Terraform
make terraform-init

# 4. Review and apply infrastructure changes
make terraform-plan
make terraform-apply

# 5. Start infrastructure services
make infra-up

# 6. Start application services
make apps-up
```

## Commands

| Command | Description |
|---|---|
| `install` | Install pipx and the pre-commit hooks |
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
