# Resource observability

This stack records up to 90 days of host and Docker resource usage so the lab's
container limits can be sized from measured peaks instead of estimates. It
collects all Docker containers automatically, including infrastructure,
applications, and sandboxes; no monitored workload needs to be changed.

## Components

- **Prometheus** retains the metrics for up to 90 days, with a 16 GB persistent
  block-storage cap.
- **cAdvisor** exposes per-container CPU, memory, network, filesystem, and
  resource-limit metrics.
- **node_exporter** exposes host CPU, memory, swap, disk, filesystem, and
  network metrics.

Prometheus is the only remotely reachable component. Its randomized, owner-only
port is advertised as the `svc:prometheus` Tailscale Service. Prometheus uses
the host network only to scrape both exporters through loopback: cAdvisor is
published at `127.0.0.1:48080` and node_exporter binds to `127.0.0.1:9100`.

## Start a measurement window

1. Copy `.env.example` to the ignored `.env` and choose an unused randomized
   `PROMETHEUS_PORT`.
2. Set `infra_prometheus_port` to the same value in the local Terraform
   variables, then apply the Terraform change so Tailscale advertises the UI.
3. Start the stack:

   ```bash
   make observability-up
   ```

4. Confirm that Prometheus shows both exporter targets as `UP` at
   `http://lab:<PROMETHEUS_PORT>/targets` over Tailscale.

Keep the stack running through normal activity, backup schedules, game
sessions, and representative Zomboid testing. Prometheus automatically removes
the oldest samples after 90 days or when its persistent blocks reach 16 GB,
whichever comes first. Stop it when the window is complete:

```bash
make observability-down
```

The data stays in `storage/prometheus` until that directory is explicitly
removed.

## Useful PromQL queries

```promql
# Largest observed container working set during the retained window.
max by (name) (max_over_time(container_memory_working_set_bytes{name!=""}[7d]))

# Container working-set pressure against its configured memory limit.
max by (name) (container_memory_working_set_bytes{name!=""})
  / max by (name) (container_spec_memory_limit_bytes{name!=""})

# CPU cores consumed by each container over the last five minutes.
sum by (name) (rate(container_cpu_usage_seconds_total{name!=""}[5m]))

# Host memory available to the kernel.
node_memory_MemAvailable_bytes
```

For the authoritative cgroup peak and limit-hit count used by the lab's sizing
rule, continue to inspect `memory.peak` and `memory.events` as documented in
the repository root `CLAUDE.md`.

## Security note

cAdvisor needs read-only access to Docker and host cgroup data. Its upstream
Docker example also requires the `privileged` capability and `/dev/kmsg` for a
complete host view. Both exporters bind only to host loopback, so Prometheus is
their only network consumer.
