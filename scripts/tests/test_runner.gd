extends SceneTree
var failures := 0
func _init() -> void:
    run_all(); quit(failures)
func assert_true(condition: bool, message: String) -> void:
    if not condition: failures += 1; print_rich("[color=red]FAIL[/color] " + message)
    else: print_rich("[color=green]PASS[/color] " + message)
func run_all() -> void:
    test_inventory_fit(); test_damage_mitigation(); test_loot_affix_count(); print("Test failures: ", failures)
func test_inventory_fit() -> void:
    var inv := InventoryGrid.new(); inv.columns = 4; inv.rows = 4; inv.initialize()
    var def := ItemDefinition.new(); def.width = 2; def.height = 2; def.id = "test"
    var item = ItemInstance.new(); item.definition = def; item.instance_guid = "abc"
    assert_true(inv.place(item, 0, 0), "2x2 item places in empty 4x4 grid")
    var item2 := ItemInstance.new(); item2.definition = def; item2.instance_guid = "def"
    assert_true(not inv.place(item2, 1, 1), "overlapping item is rejected")
func test_damage_mitigation() -> void:
    var stats := StatBlock.new(); stats.max_health = 100; stats.armor = 100
    var hc := HealthComponent.new(); hc.owner_stats = stats; get_root().add_child(hc); hc.reset_to_full()
    var packet := DamagePacket.create(hc, 50, DamagePacket.DamageType.PHYSICAL)
    var applied := hc.apply_damage(packet)
    assert_true(applied < 50, "armor reduces physical damage")
func test_loot_affix_count() -> void:
    var gen := LootGenerator.new(); get_root().add_child(gen)
    assert_true(gen.get_affix_count(ItemDefinition.Rarity.LEGENDARY) >= 4, "legendary has multiple affixes")

