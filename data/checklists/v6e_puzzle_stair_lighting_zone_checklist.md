# V6E Checklist

## Procedural puzzle rooms
- [ ] ProceduralPuzzleRoomDefinition resource created.
- [ ] Puzzle type selected: switch sequence, pressure plates, laser grid, power routing, hack nodes, or timed lockdown.
- [ ] Input sockets generated and readable from high-isometric camera.
- [ ] Reward gate set: side loot, main path, boss key, or faction cache.
- [ ] Solve logic connected to puzzle_room_solved signal.
- [ ] Puzzle lighting zones communicate active/solved/error states.

## Staircase placement rule
- [ ] StaircaseTilePlacementRules resource created.
- [ ] Stair up/down, landing, corridor, and blocked tile IDs are correct.
- [ ] Stairs have adjacent landing/corridor tiles.
- [ ] Stairs do not collide with immediate blocking wall tiles.
- [ ] Paired landing exists on expected Y level.
- [ ] Stair count per room is within budget.

## Lighting zones
- [ ] DynamicLightingZone nodes have CollisionShape3D volumes.
- [ ] PuzzleLightingZoneController assigned active, solved, and optional error zones.
- [ ] Zone lights are in target groups used by your lighting system.
- [ ] Accessibility/reduced flicker setting is respected.
