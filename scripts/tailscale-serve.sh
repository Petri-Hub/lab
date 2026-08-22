#!/usr/bin/env bash
# Advertises this host as the Tailscale Service host for every TCP-based
# lab service declared in terraform/tailscale/services.tf. The Terraform
# provider only registers a Service's name/ports/tags in the tailnet
# policy — it does not (yet) manage which device serves it, so this
# imperative step still has to run on the lab host itself. Re-run after
# adding a service here and in services.tf, or after changing a port.
#
# Best-effort: written against the documented `tailscale serve` syntax
# but not exercised against a live tailnet. Sanity-check with
# `tailscale serve --help` if a service fails to advertise.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

port_from_env() {
  local env_file="$1" var_name="$2"
  if [[ ! -f "${env_file}" ]]; then
    echo "missing ${env_file}, skipping" >&2
    return 1
  fi
  grep -E "^${var_name}=" "${env_file}" | tail -n1 | cut -d '=' -f2-
}

# svc:name -> "env_file var_name"
declare -A SERVICES=(
  ["svc:dozzle"]="services/infra/dozzle/.env DOZZLE_PORT"
  ["svc:btop"]="services/infra/btop/.env BTOP_PORT"
  ["svc:filebrowser"]="services/infra/filebrowser/.env FILEBROWSER_PORT"
  ["svc:ytdlp"]="services/apps/ytdlp/.env YTDLP_PORT"
  ["svc:kamiyomu"]="services/apps/kamiyomu/.env KAMIYOMU_PORT"
  ["svc:kavita"]="services/apps/kavita/.env KAVITA_PORT"
  ["svc:hermes"]="services/apps/hermes/.env HERMES_DASHBOARD_PORT"
  ["svc:upsnap"]="services/infra/upsnap/.env UPSNAP_PORT"
  ["svc:satisfactory-query"]="services/apps/satisfactory/.env SATISFACTORY_MESSAGING_PORT"
  ["svc:teamspeak-filetransfer"]="services/apps/teamspeak/.env TEAMSPEAK_FILE_TRANSFER_PORT"
  ["svc:teamspeak-admin"]="services/apps/teamspeak/.env TEAMSPEAK_QUERY_HTTP_PORT"
)

for svc in "${!SERVICES[@]}"; do
  read -r env_file var_name <<<"${SERVICES[$svc]}"
  if ! port="$(port_from_env "${env_file}" "${var_name}")" || [[ -z "${port}" ]]; then
    echo "skipping ${svc}: could not read ${var_name} from ${env_file}" >&2
    continue
  fi

  echo "advertising ${svc} -> tcp://localhost:${port}"
  tailscale serve --bg --service="${svc}" --tcp="${port}" "tcp://localhost:${port}"
  tailscale serve advertise "${svc}"
done
