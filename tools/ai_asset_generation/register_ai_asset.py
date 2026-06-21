"""
register_ai_asset.py
Registers a generated AI asset in a local JSON registry.
Usage:
    python register_ai_asset.py <asset_id> <source> <asset_type> <region> <raw_model_path>
Example:
    python register_ai_asset.py char_mara_voss_001 blender_sculpt character lower_grid assets/meshes/characters/char_mara_voss_001.glb
"""
import sys
import json
from pathlib import Path

REGISTRY_PATH = Path("data/ai_prompts/ai_asset_registry.json")

def load_registry():
    if REGISTRY_PATH.exists():
        return json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    return {"assets": []}

def save_registry(data):
    REGISTRY_PATH.parent.mkdir(parents=True, exist_ok=True)
    REGISTRY_PATH.write_text(json.dumps(data, indent=2), encoding="utf-8")

def register_asset(asset_id, source, asset_type, region, raw_model_path):
    registry = load_registry()
    entry = {
        "asset_id": asset_id,
        "source": source,
        "asset_type": asset_type,
        "region": region,
        "status": "raw_generated",
        "raw_model_path": raw_model_path,
        "clean_blend_path": f"art_source/blender/ai_assets_cleanup/{asset_id}_clean.blend",
        "glb_export_path": raw_model_path
    }
    existing = [a for a in registry["assets"] if a["asset_id"] == asset_id]
    if existing:
        idx = registry["assets"].index(existing[0])
        registry["assets"][idx] = entry
        print(f"Updated existing asset: {asset_id}")
    else:
        registry["assets"].append(entry)
        print(f"Registered new asset: {asset_id}")
    save_registry(registry)
    print(f"Registry saved to {REGISTRY_PATH} ({len(registry['assets'])} total assets)")

if __name__ == "__main__":
    if len(sys.argv) < 6:
        print(__doc__)
        sys.exit(1)
    register_asset(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
