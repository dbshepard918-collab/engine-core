# Procedural City Prompt Expansion

This package adds prompts and scaffolds for a top-down/high-isometric cyberpunk ARPG. Use “Diablo-like” only as a camera/readability genre reference. Do not copy maps, assets, names, icons, or layouts from any commercial game.

## Files

- `data/prompts/procedural_city_prompt_catalog.csv` — spreadsheet prompt catalog for SD 3.5 and Tripo.
- `data/prompts/procedural_city_prompt_catalog.json` — structured job catalog.
- `data/procedural/procedural_city_generation_brief.json` — district rules for city generation.
- `scripts/procedural/procedural_city_prompt_profile.gd` — Godot resource for storing prompt profiles.
- `tools/procedural_city/ascii_mask_generator.py` — deterministic test mask generator.

## Prompt intent

1. Use SD prompts for top-down map references, floorplan compositions, boss arenas, and safe hubs.
2. Use Tripo prompts for 3D modules: tile kits, landmark gates, bridges, prop clusters, and district set dressing.
3. Convert the map references into ASCII masks or JSON layouts.
4. Use the masks with your existing GridMap/DistrictGenerator systems.
