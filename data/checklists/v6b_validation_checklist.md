# V6B Validation Checklist

## Procedural dungeon entrances
- [ ] Entrance definition resource created.
- [ ] Entrance scene assigned.
- [ ] DungeonDefinition assigned.
- [ ] PlacementSocket tag matches definition socket_tag.
- [ ] DungeonEntranceActor receives dungeon_id at spawn.
- [ ] Main entrances and side entrances use different map/lighting cues.

## Tile placement validation
- [ ] GridMap assigned to TilePlacementValidator.
- [ ] MeshLibrary assigned to GridMap.
- [ ] Doorway tiles have valid neighboring floor/corridor cells.
- [ ] Dungeon entrance tiles have nearby dungeon sockets.
- [ ] Hazard tiles do not block required critical path.
- [ ] Dynamic light budget is under target.

## Dynamic lighting
- [ ] TileDynamicLightProfile created for district.
- [ ] Light sockets placed on tile scenes.
- [ ] TileDynamicLightSpawner added to tile/entrance scenes.
- [ ] Distance fade enabled for repeated lights.
- [ ] Shadow casting disabled unless the light is gameplay-critical.
- [ ] Flicker tested for accessibility/reduce flashing rules.
