# Secure Tripo API Setup

## Critical security rule
Do **not** paste your Tripo API key into scripts, Word documents, Git commits, screenshots, bug reports, prompt catalogs, or shared build logs.

## Local setup

### macOS/Linux
```bash
export TRIPO_API_KEY="your_key_here"
export TRIPO_API_BASE="https://openapi.tripo3d.ai"
export TRIPO_MODEL="v3.1-20260211"
python tools/tripo_api/tripo_client.py
```

### Windows PowerShell
```powershell
$env:TRIPO_API_KEY="your_key_here"
$env:TRIPO_API_BASE="https://openapi.tripo3d.ai"
$env:TRIPO_MODEL="v3.1-20260211"
python tools/tripo_api/tripo_client.py
```

## Git ignore
Add this to `.gitignore`:

```gitignore
.env
*.env
tripo_job_response.json
```

## Blender plugin usage
When using the Tripo Blender plugin, enter the key in the plugin UI or use local environment variables if supported by your setup. Do not write the key into Blender Python scripts.
