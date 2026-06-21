class_name MaterialWallet
extends Resource

signal materials_changed

@export var materials: Dictionary = {} # material_id -> count
@export var currency: int = 0

func has_materials(cost: Dictionary) -> bool:
    for id in cost.keys():
        if int(materials.get(id, 0)) < int(cost[id]): return false
    return true

func consume_materials(cost: Dictionary) -> bool:
    if not has_materials(cost): return false
    for id in cost.keys():
        materials[id] = int(materials.get(id, 0)) - int(cost[id])
    materials_changed.emit()
    return true

func add_material(id: String, count: int) -> void:
    materials[id] = int(materials.get(id, 0)) + count
    materials_changed.emit()

func can_pay(amount: int) -> bool:
    return currency >= amount

func pay(amount: int) -> bool:
    if currency < amount: return false
    currency -= amount
    materials_changed.emit()
    return true
