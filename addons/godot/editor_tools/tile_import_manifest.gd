@tool
class_name TileImportManifest
extends Resource

@export var tile_set_id: String = "lower_grid"
@export var source_glb_folder: String = "res://assets/meshes/tiles/lower_grid"
@export var output_scene_folder: String = "res://scenes/tiles/lower_grid"
@export var mesh_library_output_path: String = "res://data/tile_sets/lower_grid_mesh_library.tres"
@export var cell_size: Vector3 = Vector3(4, 4, 4)
@export var create_collision: bool = true
@export var create_navigation: bool = false
@export var tile_ids: Array[String] = []
