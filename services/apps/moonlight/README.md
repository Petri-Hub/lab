# Moonlight

[Moonlight Web Stream](https://github.com/MrCreativ3001/moonlight-web-stream) connects to Sunshine and streams to a browser. Cloudflare Access protects the HTTPS page and WebRTC signaling. Cloudflare Realtime TURN relays media when the browser or lab cannot connect directly. The browser does not need Tailscale or a Moonlight installation.

```text
Browser -> Cloudflare Access -> tunnel -> nginx -> Moonlight Web -> Sunshine (LAN)
Browser <---------------- WebRTC, via TURN if needed ----------------> Moonlight Web
```

## Setup

1. Create a [Cloudflare Realtime TURN key](https://developers.cloudflare.com/realtime/turn/generate-credentials/). Store the key ID and API token in 1Password. Copy `.env.example` to `.env` and set `MOONLIGHT_TURN_KEY_ID` and `MOONLIGHT_TURN_API_TOKEN`. The API token stays on the server; the script issues credentials valid for 24 hours per negotiation. Provisioning Realtime and any billing settings is separate from this Terraform configuration.
2. Set `infra_moonlight_subdomain_url` in the local Terraform variables and `NGINX_MOONLIGHT_DOMAIN` in `services/infra/nginx/.env` to the resulting full hostname. Review `make terraform-plan` and apply it. The generic Cloudflare Access policy uses the lab's existing authorized email list. Recreate NGINX to load the new environment and template.
3. Create `storage/moonlight` and make it writable by the image's `moonlight` user (UID/GID 999 in v3.0.1). Start the application with the apps aggregate. Its data directory contains user accounts and paired-host identity; protect it and back it up if you need to restore pairings. It is not currently included in Restic.
4. Open the HTTPS hostname, authenticate with Cloudflare Access, and immediately create the first Moonlight Web user; it becomes the administrator. Store that password in 1Password. Add the Sunshine host by its LAN IP, pair it, and enter the PIN in Sunshine's existing admin UI. Use a DHCP reservation for the host or update the saved address if it changes.
5. Select WebRTC in the stream settings and test video, audio and input from a browser outside the home network. The stream uses TURN when direct ICE connectivity fails; no router port forwarding or public Sunshine port is required for the relay path. Verify the selected ICE candidate and latency in browser WebRTC diagnostics. TCP/TLS TURN on port 443 can help on restrictive networks, but a network or browser can still block it.

The existing Cloudflare Tunnel is for the page and signaling. Do not select the application's WebSocket video transport through the public tunnel: Cloudflare's [video delivery policy](https://developers.cloudflare.com/fundamentals/reference/policies-compliances/delivering-videos-with-cloudflare/) applies to public Tunnel routes. TURN is a separate paid service: consult [current pricing](https://developers.cloudflare.com/realtime/sfu/platform/pricing/) and monitor usage. If TURN credential generation fails, the app logs an error and direct ICE may still work; do not assume the relay is active without testing it.

## Verification and sizing

The 256 MB limit is an initial ceiling, not a measured peak. After a representative streaming session, check the container's cgroup `memory.peak` and `memory.events` using the procedure in `CLAUDE.md`, then adjust the limit and total budget. The lab-to-host LAN path and the full browser-to-Sunshine stream must both be tested after deployment. If pairing fails, check Sunshine's firewall and LAN access. If the page works but streaming fails, check TURN credentials, the browser's selected ICE candidates, and network restrictions.
