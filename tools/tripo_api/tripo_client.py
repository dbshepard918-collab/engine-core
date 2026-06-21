
"""
Secure Tripo API client scaffold.

IMPORTANT:
- Do not hard-code your Tripo API key in this file.
- Store it in an environment variable named TRIPO_API_KEY or a local .env file that is excluded from Git.
- This scaffold intentionally does not include any real secret.
"""

import os
import json
import time
from pathlib import Path

try:
    import requests
except ImportError as exc:
    raise SystemExit("Install requests in your pipeline environment: pip install requests") from exc

API_BASE = os.environ.get("TRIPO_API_BASE", "https://openapi.tripo3d.ai").rstrip("/")
API_KEY = os.environ.get("TRIPO_API_KEY", "")
DEFAULT_MODEL = os.environ.get("TRIPO_MODEL", "v3.1-20260211")

if not API_KEY:
    raise SystemExit("TRIPO_API_KEY is not set. Set it in your shell or local .env loader before running this script.")

HEADERS = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {API_KEY}",
}


def submit_text_to_model(prompt: str, texture: bool = True, pbr: bool = True, texture_quality: str = "detailed") -> dict:
    """Submit a text-to-model job. Endpoint/parameters should be verified against your current Tripo plan/docs."""
    url = f"{API_BASE}/v3/generation/text-to-model"
    payload = {
        "prompt": prompt,
        "model": DEFAULT_MODEL,
        "texture": texture,
        "pbr": pbr,
        "texture_quality": texture_quality,
    }
    response = requests.post(url, headers=HEADERS, data=json.dumps(payload), timeout=60)
    response.raise_for_status()
    return response.json()


def save_job_response(response: dict, output_path: str) -> None:
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    Path(output_path).write_text(json.dumps(response, indent=2), encoding="utf-8")


if __name__ == "__main__":
    prompt = "original cyberpunk compact medical drone, clean game asset design, no logos, no text"
    result = submit_text_to_model(prompt)
    save_job_response(result, "tripo_job_response.json")
    print(json.dumps(result, indent=2))
