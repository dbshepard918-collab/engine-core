
import random, json
from pathlib import Path

POI_TYPES = ["town_hub", "fast_travel", "vendor", "crafting", "world_event", "elite_patrol", "stronghold", "boss_gate", "lore", "resource_node", "dungeon_entrance"]

def generate_region(region_id="lower_grid", w=64, h=64, seed=9001):
    random.seed(seed)
    pois = []
    def add(id, typ, x, y, dungeon_id=""):
        pois.append({"id": id, "type": typ, "grid": [x,y], "dungeon_id": dungeon_id})
    add(f"{region_id}_hub", "town_hub", 6, h//2)
    add(f"{region_id}_fast_travel_01", "fast_travel", 8, h//2+2)
    add(f"{region_id}_stronghold_01", "stronghold", w-14, h//2)
    add(f"{region_id}_boss_gate", "boss_gate", w-6, h//2)
    for i in range(5):
        add(f"{region_id}_dungeon_{i+1:02d}", "dungeon_entrance", random.randint(12,w-12), random.randint(8,h-8), f"{region_id}_proc_dungeon_{i+1:02d}")
    for i in range(10):
        add(f"{region_id}_event_{i+1:02d}", random.choice(["world_event","elite_patrol","lore","resource_node"]), random.randint(8,w-8), random.randint(6,h-6))
    roads = []
    for x in range(6, w-5): roads.append([x, h//2])
    return {"region_id": region_id, "size": [w,h], "seed": seed, "main_road": roads, "pois": pois}

if __name__ == '__main__':
    graph = generate_region()
    out = Path('open_world_region_graph.json')
    out.write_text(json.dumps(graph, indent=2), encoding='utf-8')
    print(out.read_text())
