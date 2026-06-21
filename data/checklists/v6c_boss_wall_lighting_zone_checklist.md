# V6C Checklist

## Procedural boss rooms
- [ ] Boss room definition resource created.
- [ ] Boss room floor, wall, doorway, hazard, and cover tile IDs assigned.
- [ ] Entrance and exit directions assigned.
- [ ] Boss spawn, add spawn, reward, and boss gate sockets generated.
- [ ] Lighting zone profile assigned.
- [ ] Encounter can start, phase-change lighting can apply, and clear state unlocks exit.

## Wall placement rules
- [ ] WallTilePlacementRules resource created for the tile set.
- [ ] Solid wall, doorway, corner, and floor IDs are correct.
- [ ] Doorways connect two walkable cells.
- [ ] Walls touch at least one walkable side unless marked as boundary filler.
- [ ] Corners have expected wall/floor neighbor mix.

## Dynamic lighting zones
- [ ] Area3D zone has CollisionShape3D.
- [ ] Zone profile assigned.
- [ ] Player group name matches project settings.
- [ ] Lights are in tile_dynamic_lights group.
- [ ] Boss phase color overrides tested.
- [ ] Accessibility setting can reduce flicker or disable phase flashing.
