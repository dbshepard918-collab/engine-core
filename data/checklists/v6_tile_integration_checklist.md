# V6 Tile Integration Checklist

## Blender
- [ ] Tile mesh dimensions follow the 4m grid standard.
- [ ] Object names match final tile IDs.
- [ ] Transforms applied.
- [ ] Origin and pivot are grid-centered.
- [ ] Collision proxies are simple and named `COLLISION_*`.
- [ ] Emissive details use separate material slots.
- [ ] Exported GLB files are in the Godot project under `res://assets/meshes/tiles/[set]/`.

## Godot import
- [ ] GLB files appear in FileSystem dock.
- [ ] Imported materials checked.
- [ ] Tile scenes generated.
- [ ] MeshLibrary generated.
- [ ] GridMap cell size set to 4,4,4.
- [ ] Test map paints floor/wall/door/corner/stair/bridge tiles.
- [ ] Collision tested with player controller.
- [ ] Navigation mesh baked and tested with enemies.
- [ ] POI and dungeon entrance scenes placed on sockets.
- [ ] Performance budget test run in dense scene.
