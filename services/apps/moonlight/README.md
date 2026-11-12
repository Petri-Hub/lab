# Moonlight

[Moonlight-Web](https://github.com/linckosz/moonlight-web) is a browser client for Sunshine and other GameStream hosts. Sunshine runs on the gaming PC; this container runs on the lab and forwards the PC's encoded video, audio and input to the browser. It does not capture or encode the lab's screen and needs no GPU access.

```text
Browser <--- HTTPS and direct WebRTC ---> lab: Moonlight <--- LAN ---> gaming PC: Sunshine
```

This branch is a **LAN evaluation** of the alternative to [#43](https://github.com/Petri-Hub/lab/pull/43). It does not implement #43's remote-access requirements. This version does not provide a configured TURN relay, and its frontend drops TURN candidates. A Cloudflare Tunnel can proxy the interface and signaling but cannot on its own deliver direct WebRTC media to an outside browser. The WebSocket stream fallback would traverse the tunnel and is not a substitute for the TURN design in #43. Internet access and UPnP are disabled for this evaluation; review a supported remote media path before deploying for use outside the LAN.

## Setup

1. Copy `.env.example` to `.env` and set two unused, non-privileged lab host ports and the UID and GID that will own the data directory. Create `storage/moonlight` owned by that user. The volume contains the paired-client identity and the app's authentication material; it is not included in Restic yet.
2. Start the service with the apps aggregate. Host networking is required for direct WebRTC and LAN discovery; it is an exception to the shared Docker network convention. The HTTP and HTTPS listeners bind on the host, so restrict access with the lab's firewall. WebRTC also uses UDP ports 48550–48573 and may use the same TCP range; see the [upstream port reference](https://github.com/linckosz/moonlight-web/blob/v0.4.3/docker/README.md#ports) and restrict these to trusted clients.
3. Follow the [upstream container setup](https://github.com/linckosz/moonlight-web/blob/v0.4.3/docker/README.md) to set the admin password and access PIN. Store both in 1Password. Avoid sharing command output containing the PIN. Open the lab host's HTTPS port on the LAN and accept the self-signed certificate for the evaluation.
4. Add the gaming PC by its LAN IP if discovery does not find it. Enter the PIN shown by Moonlight-Web in the Sunshine web interface on the gaming PC. Test a stream from another LAN browser, including video, audio, keyboard, mouse and gamepad. Ensure the lab can reach Sunshine's GameStream TCP and UDP ports.

## Limits and comparison

- The 256 MB memory limit is provisional. Measure `memory.peak` and `memory.events` during a representative stream and check the lab's total memory budget before enabling the service permanently.
- Compared with #43, this app offers a different UI, browser-side enhancements and a native host engine. The native engine and microphone forwarding to the lab's local audio device do not provide those features on the separate Sunshine PC.
- #43 supports a Cloudflare TURN configuration for restrictive networks. This branch intentionally does not claim the same remote reachability, Cloudflare Access integration or relay behavior. Both need an end-to-end streaming test and measured resource usage.
