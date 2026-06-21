class_name MinimapTextureBaker
extends Node

@export var color_floor: Color = Color(0.12, 0.12, 0.16, 1)
@export var color_wall: Color = Color(0.02, 0.02, 0.04, 1)
@export var color_door: Color = Color(0.0, 0.8, 1.0, 1)
@export var color_hazard: Color = Color(1.0, 0.15, 0.28, 1)
@export var pixels_per_cell: int = 4

func bake(mask: Array[String]) -> ImageTexture:
    var h := mask.size()
    var w := mask[0].length() if h > 0 else 0
    var img := Image.create(w * pixels_per_cell, h * pixels_per_cell, false, Image.FORMAT_RGBA8)
    for y in range(h):
        for x in range(w):
            var col := color_floor
            match mask[y][x]:
                "#": col = color_wall
                "D": col = color_door
                "H": col = color_hazard
                _: col = color_floor
            fill_cell(img, x, y, col)
    return ImageTexture.create_from_image(img)

func fill_cell(img: Image, cx: int, cy: int, col: Color) -> void:
    for py in range(pixels_per_cell):
        for px in range(pixels_per_cell):
            img.set_pixel(cx * pixels_per_cell + px, cy * pixels_per_cell + py, col)
