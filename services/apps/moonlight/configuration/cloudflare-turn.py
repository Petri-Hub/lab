#!/usr/bin/python3
"""Issue short-lived TURN credentials for one WebRTC negotiation."""

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request


def main():
    key_id = urllib.parse.quote(os.environ["MOONLIGHT_TURN_KEY_ID"], safe="")
    token = os.environ["MOONLIGHT_TURN_API_TOKEN"]
    request = urllib.request.Request(
        f"https://rtc.live.cloudflare.com/v1/turn/keys/{key_id}/credentials/generate-ice-servers",
        data=json.dumps({"ttl": 86400}).encode(),
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=10) as response:
        servers = json.load(response)["iceServers"]
    if not isinstance(servers, list) or not servers:
        raise ValueError("No ICE servers returned")
    json.dump(servers, sys.stdout)


if __name__ == "__main__":
    try:
        main()
    except (KeyError, ValueError, OSError, urllib.error.URLError):
        print("Could not obtain Cloudflare TURN credentials", file=sys.stderr)
        sys.exit(1)
