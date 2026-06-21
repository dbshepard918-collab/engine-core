
"""
Batch runner scaffold for Tripo prompt catalog.
No API key is stored here. Set TRIPO_API_KEY in your local environment.
Verify endpoint names and response fields against your active Tripo account/docs before production use.
"""
import os, json, time
from pathlib import Path
import requests

API_BASE = os.environ.get("TRIPO_API_BASE", "https://openapi.tripo3d.ai").rstrip("/")
API_KEY = os.environ.get("TRIPO_API_KEY", "")
MODEL = os.environ.get("TRIPO_MODEL", "v3.1-20260211")
CATALOG = Path("tools/tripo_api/tripo_prompt_batch_expanded.json")
OUT_DIR = Path("tripo_jobs")

if not API_KEY:
    raise SystemExit("Set TRIPO_API_KEY before running.")

HEADERS = {"Content-Type": "application/json", "Authorization": f"Bearer {API_KEY}"}


def submit_text_to_model(job: dict) -> dict:
    url = f"{API_BASE}/v3/generation/text-to-model"
    params = job.get("parameters", {})
    payload = {
        "prompt": job["prompt"],
        "model": MODEL,
        "texture": params.get("texture", True),
        "pbr": params.get("pbr", True),
        "texture_quality": params.get("texture_quality", "detailed"),
    }
    # Some API/provider variants support extra fields such as negative_prompt,
    # face_limit, quad, smart_low_poly, geometry_quality, export_uv, and generate_parts.
    # Keep them in payload only if your current endpoint accepts them.
    for k in ["negative_prompt"]:
        if job.get(k): payload[k] = job[k]
    for k in ["face_limit", "quad", "smart_low_poly", "generate_parts", "export_uv", "geometry_quality"]:
        if k in params: payload[k] = params[k]
    r = requests.post(url, headers=HEADERS, data=json.dumps(payload), timeout=60)
    r.raise_for_status()
    return r.json()


def main(limit: int = 0):
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    OUT_DIR.mkdir(exist_ok=True)
    jobs = data["jobs"][:limit or None]
    for job in jobs:
        print("Submitting", job["id"])
        response = submit_text_to_model(job)
        (OUT_DIR / f"{job['id']}_response.json").write_text(json.dumps(response, indent=2), encoding="utf-8")
        time.sleep(1)

if __name__ == "__main__":
    main()
