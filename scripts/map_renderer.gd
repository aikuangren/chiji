extends Node2D
class_name MapRenderer

# 地图渲染器 - 使用规则瓦片素材拼接战斗地图

const MAP_TEXTURE = preload("res://assets/maps/tactical_tileset.png")
const SHOW_REFERENCE_GRID = false

var _region_names = {
	MapData.RegionType.FOREST: "森林",
	MapData.RegionType.PLAINS: "平原",
	MapData.RegionType.CITY: "城市废墟",
	MapData.RegionType.DESERT: "沙漠"
}

func _ready():
	print("战术瓦片地图加载完成!")

func _draw():
	_draw_tile_map()
	if SHOW_REFERENCE_GRID:
		_draw_grid()

func _draw_tile_map() -> void:
	var source_tile_size := MAP_TEXTURE.get_size() / Vector2(MapTileData.ATLAS_COLUMNS, MapTileData.ATLAS_ROWS)
	
	for y in range(MapTileData.GRID_COUNT):
		for x in range(MapTileData.GRID_COUNT):
			var cell := Vector2i(x, y)
			var atlas_cell := MapTileData.get_atlas_cell(cell)
			var source_rect := Rect2(Vector2(atlas_cell) * source_tile_size, source_tile_size)
			draw_texture_rect_region(MAP_TEXTURE, MapTileData.get_world_rect(cell), source_rect)

func _draw_grid():
	var map_size = MapData.MAP_SIZE
	var grid_color = Color(1, 1, 1, 0.055)
	var y = -map_size
	while y <= map_size:
		draw_line(Vector2(-map_size, y), Vector2(map_size, y), grid_color, 1.0)
		y += MapTileData.GRID_SIZE
	var x = -map_size
	while x <= map_size:
		draw_line(Vector2(x, -map_size), Vector2(x, map_size), grid_color, 1.0)
		x += MapTileData.GRID_SIZE

func get_player_region(player_pos: Vector2) -> String:
	var region_type = MapData.get_region_at(player_pos.x, player_pos.y)
	return _region_names[region_type]

func get_player_region_type(player_pos: Vector2) -> MapData.RegionType:
	return MapData.get_region_at(player_pos.x, player_pos.y)
