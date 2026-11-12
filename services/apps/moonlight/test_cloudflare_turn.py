import contextlib
import importlib.util
import io
import json
import os
import unittest
from pathlib import Path
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "cloudflare_turn", Path(__file__).parent / "configuration/cloudflare-turn.py"
)
turn = importlib.util.module_from_spec(spec)
spec.loader.exec_module(turn)


class TurnCredentialsTest(unittest.TestCase):
    def test_requests_ephemeral_credentials_and_returns_ice_list(self):
        servers = [{"urls": ["turns:turn.example:443"], "username": "user", "credential": "secret"}]
        response = io.BytesIO(json.dumps({"iceServers": servers}).encode())
        output = io.StringIO()
        with patch.dict(os.environ, {"MOONLIGHT_TURN_KEY_ID": "test-id", "MOONLIGHT_TURN_API_TOKEN": "test-token"}), patch.object(turn.urllib.request, "urlopen", return_value=response) as urlopen, contextlib.redirect_stdout(output):
            turn.main()
        request = urlopen.call_args.args[0]
        self.assertEqual(request.full_url, "https://rtc.live.cloudflare.com/v1/turn/keys/test-id/credentials/generate-ice-servers")
        self.assertEqual(request.get_header("Authorization"), "Bearer test-token")
        self.assertEqual(json.loads(request.data), {"ttl": 86400})
        self.assertEqual(json.loads(output.getvalue()), servers)

    def test_rejects_empty_ice_list(self):
        response = io.BytesIO(b'{"iceServers": []}')
        with patch.dict(os.environ, {"MOONLIGHT_TURN_KEY_ID": "test-id", "MOONLIGHT_TURN_API_TOKEN": "test-token"}), patch.object(turn.urllib.request, "urlopen", return_value=response), self.assertRaises(ValueError):
            turn.main()


if __name__ == "__main__":
    unittest.main()
