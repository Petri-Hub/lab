# Lab — Agent Guide

A personal homelab running on a single laptop — infrastructure and applications managed entirely as code, secured by design, and built for reliability without the overhead of a data center. Every service is defined in Docker Compose with explicit configuration, resource limits, and randomized ports. Terraform manages Cloudflare (tunnels, DNS, Access policies) and Tailscale (ACLs, device tags). All services share a common Docker network and follow consistent conventions for naming, environment variables, directory layout, and security.

## Folder structure

```
.
├── docker/                           # Custom Docker images (built locally)
│   └── <service-name>/
│       └── Dockerfile
├── services/
│   ├── infra/                        # Infrastructure — monitoring, networking, backups, access
│   │   ├── compose.yml               # Aggregates all infra services via `include:`
│   │   └── <service-name>/
│   │       ├── configuration/        # Static config files mounted into the container
│   │       ├── .env                  # Local environment values (gitignored)
│   │       ├── .env.example          # Documented variables with placeholder values
│   │       └── compose.yml           # Service definition
│   └── apps/                         # Applications — user-facing tools
│       ├── compose.yml               # Aggregates all app services via `include:`
│       └── <service-name>/
│           ├── .env
│           ├── .env.example
│           └── compose.yml
├── terraform/                        # Infrastructure-as-Code for external providers
│   ├── main.tf                       # Root module wiring
│   ├── providers.tf                  # Provider configuration and versions
│   ├── variables.tf                  # Root-level variables
│   └── <provider>/                   # Submodule: provider-specific resources
│       ├── main.tf
│       ├── variables.tf
│       └── providers.tf
└── storage/                          # Persistent data (gitignored)
    └── <service-name>/
```

Services are split into two categories: **infrastructure** (what keeps the server running and observable) and **applications** (what makes the server useful). Each lives under `services/infra/` or `services/apps/`, is aggregated by the parent `compose.yml` via the `include:` directive, and follows the same internal layout.

## General rules

### Keep configuration in a dedicated folder

Every service that needs static config files places them in a `configuration/` subdirectory. This keeps mounts predictable and organized, with a single place to look for a service's settings. Separating static configuration from the Compose definition avoids cluttering the service root, makes volume mounts obvious, and lets you version-config separately from runtime configuration.

**Good:**

```yaml
# services/infra/nginx/compose.yml
volumes:
  - ./configuration/nginx.conf.template:/etc/nginx/templates/nginx.conf.template:ro
```

**Bad:**

```yaml
volumes:
  - ./nginx.conf.template:/etc/nginx/templates/nginx.conf.template:ro
```

### Prefix environment variables with the service name

Variables are prefixed with the service name in uppercase to avoid collisions and make it clear what each one controls. Without prefixes, generic names like `PORT`, `DOMAIN`, or `PASSWORD` clash between services in the shared network. The prefix creates a flat, collision-free namespace and makes it obvious which service owns each variable when reading logs, scripts, or dashboards.

**Good:**

```bash
# services/apps/satisfactory/.env.example
SATISFACTORY_MAX_PLAYERS=4
SATISFACTORY_GAME_PORT=7328
SATISFACTORY_MESSAGING_PORT=1273
```

```bash
# services/infra/rclone/.env.example
RCLONE_RESTIC_PORT=2810
```

**Bad:**

```bash
# services/apps/satisfactory/.env.example
MAX_PLAYERS=4
GAME_PORT=7328
MESSAGING_PORT=1273
```

### Separate infra from apps

Infrastructure services handle monitoring, networking, and backups. Application services are the actual tools being hosted. This split keeps concerns clean — you know what keeps the server running versus what makes it useful. Mixing foundational services (proxies, loggers, schedulers) with user-facing tools (game servers, downloaders) obscures the boundary between platform and product. The split clarifies ownership, makes it safe to restart all apps without touching infra, and documents intent by directory alone.

**Good:**

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

**Bad:**

```
services/
├── btop/
├── cloudflared/
├── dozzle/
├── nginx/
├── ofelia/
├── rclone/
├── restic/
├── satisfactory/
└── ytdlp/
```

### Set resource limits on every container

Every service declares how much CPU and memory it can use. This prevents any single service from spiking and starving the others, keeping the whole lab stable under load. On a single laptop without resource caps, a misbehaving container (e.g. a Satisfactory map pre-generation spike) can exhaust host memory or saturate CPU, taking down the entire stack. Explicit limits guarantee predictable behavior and survival under load.

**Good:**

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 64M
```

**Bad:**

```yaml
# no deploy block — container runs without constraints
```

### Use environment variables for port randomization

No service uses its default port. Every exposed port is set through an environment variable, making it easy to change and harder for automated scans to find services. Internal ports stay at their well-known defaults; only the externally-facing port is randomized. Default ports are the first thing scanners check. Mapping a randomized host port to a well-known internal port preserves standard container behavior while hiding services from port-scanning bots on the public internet.

**Good:**

```yaml
# services/infra/btop/compose.yml
ports:
  - "${BTOP_PORT}:7681"
```

```yaml
# services/infra/dozzle/compose.yml
ports:
  - "${DOZZLE_PORT}:8080"
```

**Bad:**

```yaml
ports:
  - "7681:7681"
```

```yaml
ports:
  - "8080:8080"
```

### Connect every service to the same network

All services join a shared Docker network so they can resolve each other by container name without complex networking setup. Service discovery via container name on a shared network eliminates hard-coded IPs, manual `/etc/hosts` entries, and per-service networking configuration. Any new service can immediately reach any other service by its `container_name` without additional wiring.

**Good:**

```yaml
networks:
  lab:
    name: lab
    external: true
```

Every service's Compose file includes the above block and a `networks: [lab]` entry.

**Bad:**

```yaml
# Each service on its own default network — cannot resolve other containers by name
```

### Follow container conventions

Every container uses restart policies so services recover from crashes or host reboots without manual intervention. Container names are set explicitly to match their Compose service key, keeping references unambiguous across the stack. Without `restart: unless-stopped`, a crash after a kernel update or OOM kill leaves the service down until noticed. Explicit `container_name` prevents Docker from generating random names, making logs, networking, and references predictable.

**Good:**

```yaml
services:
  rclone:
    container_name: rclone
    restart: unless-stopped
```

**Bad:**

```yaml
services:
  rclone:
    container_name: rclone-server
    restart: always
```

### Use `.env.example` to document variables

Every service provides a `.env.example` file listing all required environment variables with documented placeholder values. The actual `.env` file (gitignored) contains real values and is never committed. The `.env.example` serves as living documentation of what a service needs to run. A new contributor or agent can copy `.env.example` to `.env` and fill in values without hunting through Compose files or source code for variable names.

**Good:**

```bash
# services/infra/rclone/.env.example
RCLONE_RESTIC_PORT=2810
```

**Bad:**

```bash
# No .env.example — variables must be reverse-engineered from compose.yml
```

### Everything as code

Terraform manages Cloudflare tunnels, DNS records, Access policies, and Tailscale ACLs. Docker Compose defines every service. There are no SSH-and-pray manual steps — infrastructure is versioned, reviewed, and applied declaratively. Manual configuration drifts silently and cannot be reproduced. Codified infrastructure ensures every change is tracked in git, reviewable in PRs, and rollback-able to any prior state. The entire lab can be rebuilt from scratch with `make setup && terraform apply && make infra-up`.

**Good:**

- Terraform modules for Cloudflare (tunnel, DNS, Access) and Tailscale (ACLs, tags)
- Makefile targets: `terraform-init`, `terraform-plan`, `terraform-apply`
- Docker Compose with `include:` aggregates

**Bad:**

- Modifying Cloudflare tunnel config through the web dashboard
- Editing Tailscale ACLs manually through the admin console
- SSH-ing into the server to start containers by hand

### Use aggregates in parent Compose files

Each category (`services/infra/`, `services/apps/`) has a `compose.yml` that includes all its child services. This enables starting/stopping entire categories with a single command while keeping each service in its own self-contained file. Aggregating via `include:` preserves single-responsibility per file. You can iterate on a service in isolation (`docker compose -f services/infra/btop/compose.yml up -d`) or operate on the whole category (`docker compose -f services/infra/compose.yml up -d`). No giant monolith Compose file.

**Good:**

```yaml
# services/infra/compose.yml
include:
  - ./cloudflared/compose.yml
  - ./dozzle/compose.yml
  - ./filebrowser/compose.yml
  - ./nginx/compose.yml
  - ./ofelia/compose.yml
  - ./rclone/compose.yml
  - ./restic/compose.yml
  - ./btop/compose.yml
```

**Bad:**

```yaml
# Single monolithic 300-line compose.yml with all services in one file
```
