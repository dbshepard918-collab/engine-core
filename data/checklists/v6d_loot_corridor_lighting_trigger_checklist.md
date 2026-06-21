# V6D Checklist

## Procedural loot rooms
- [ ] ProceduralLootRoomDefinition resource created.
- [ ] Floor, wall, doorway, and reward scenes assigned.
- [ ] Common and rare loot sockets generated.
- [ ] Lock type tested: none/key/hack/guard/event/boss clear.
- [ ] LightingTrigger created for loot reveal or ambush alert.
- [ ] Loot room branches from corridor or side path, not forced critical-path blockage.

## Corridor placement rules
- [ ] CorridorTilePlacementRules resource created.
- [ ] Corridor floor, doorway, wall, intersection, and entrance IDs are correct.
- [ ] Corridor dead-end count is within budget.
- [ ] Dead ends terminate at loot/event/lore/reward content.
- [ ] Room transitions use doorway tiles.
- [ ] Corridors have enough wall/border support to read clearly.

## Lighting triggers
- [ ] LightingTriggerProfile created.
- [ ] LightingTrigger Area3D has CollisionShape3D.
- [ ] Trigger required_group matches player group.
- [ ] Target lights are in profile target_group.
- [ ] One-shot loot reveal tested.
- [ ] Exit/deactivate behavior tested if enabled.
