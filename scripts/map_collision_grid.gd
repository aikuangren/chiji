extends Node2D
class_name MapCollisionGrid

const GRID_SIZE := 125
const GRID_COUNT := 32
const TERRAIN_LAYER := 2

@export var debug_draw := false
@export var collision_enabled := true

func _ready() -> void:
	if collision_enabled:
		_build_collision_shapes()
	queue_redraw()

func _draw() -> void:
	if not debug_draw:
		return
	
	_draw_blocked_areas()
	_draw_reference_grid()

func is_world_position_blocked(world_position: Vector2) -> bool:
	return MapTileData.is_blocked_cell(world_to_cell(world_position))

func world_to_cell(world_position: Vector2) -> Vector2i:
	return MapTileData.world_to_cell(world_position)

func cell_to_world(cell: Vector2i) -> Vector2:
	return MapTileData.cell_to_world(cell)

func _build_collision_shapes() -> void:
	var body := StaticBody2D.new()
	body.name = "TerrainTiles"
	body.collision_layer = TERRAIN_LAYER
	body.collision_mask = 0
	add_child(body)
	
	for y in range(MapTileData.GRID_COUNT):
		for x in range(MapTileData.GRID_COUNT):
			var cell := Vector2i(x, y)
			if not MapTileData.is_blocked_cell(cell):
				continue
			
			var world_rect := MapTileData.get_world_rect(cell)
			var shape := CollisionShape2D.new()
			shape.name = "Block_%02d_%02d" % [x, y]
			shape.position = world_rect.position + world_rect.size * 0.5
			
			var rectangle := RectangleShape2D.new()
			rectangle.size = world_rect.size
			shape.shape = rectangle
			body.add_child(shape)

func _draw_blocked_areas() -> void:
	for y in range(MapTileData.GRID_COUNT):
		for x in range(MapTileData.GRID_COUNT):
			var cell := Vector2i(x, y)
			if not MapTileData.is_blocked_cell(cell):
				continue
			
			var world_rect := MapTileData.get_world_rect(cell)
			draw_rect(world_rect, Color(1.0, 0.0, 0.0, 0.16), true)
			draw_rect(world_rect, Color(1.0, 0.12, 0.08, 0.65), false, 2.0)

func _draw_reference_grid() -> void:
	var map_size := MapData.MAP_SIZE
	var grid_color := Color(1.0, 0.16, 0.12, 0.18)
	for i in range(MapTileData.GRID_COUNT + 1):
		var offset := -map_size + i * MapTileData.GRID_SIZE
		draw_line(Vector2(-map_size, offset), Vector2(map_size, offset), grid_color, 1.0)
		draw_line(Vector2(offset, -map_size), Vector2(offset, map_size), grid_color, 1.0)
