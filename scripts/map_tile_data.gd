extends RefCounted
class_name MapTileData

const GRID_SIZE := 125
const GRID_COUNT := 32
const ATLAS_COLUMNS := 16
const ATLAS_ROWS := 16

const KIND_GROUND := "ground"
const KIND_BLOCK := "block"

# 先只用两种瓦片，避免画面过杂：一种地面，一种阻挡。
const GROUND_TILE := Vector2i(1, 1)
const BLOCK_TILE := Vector2i(0, 4)

# 简单 FC 坦克大战式地图：地面默认可走，以下矩形为阻挡。
const BLOCKED_RECTS := [
	Rect2i(0, 0, 32, 1),
	Rect2i(0, 31, 32, 1),
	Rect2i(0, 0, 1, 32),
	Rect2i(31, 0, 1, 32),
	
	Rect2i(4, 4, 3, 4),
	Rect2i(10, 3, 2, 6),
	Rect2i(16, 4, 4, 3),
	Rect2i(25, 4, 3, 5),
	
	Rect2i(3, 11, 6, 2),
	Rect2i(13, 10, 2, 5),
	Rect2i(18, 11, 5, 2),
	Rect2i(27, 11, 2, 5),
	
	Rect2i(6, 18, 3, 5),
	Rect2i(12, 19, 5, 2),
	Rect2i(21, 18, 2, 5),
	Rect2i(26, 19, 4, 2),
	
	Rect2i(3, 26, 4, 2),
	Rect2i(10, 25, 2, 4),
	Rect2i(16, 25, 4, 3),
	Rect2i(24, 25, 3, 4),
	
	Rect2i(15, 7, 2, 3),
	Rect2i(15, 22, 2, 3),
	Rect2i(7, 15, 3, 2),
	Rect2i(22, 15, 3, 2)
]

static func get_tile_kind(cell: Vector2i) -> String:
	if cell.x < 0 or cell.y < 0 or cell.x >= GRID_COUNT or cell.y >= GRID_COUNT:
		return KIND_BLOCK
	
	for rect in BLOCKED_RECTS:
		if rect.has_point(cell):
			return KIND_BLOCK
	
	return KIND_GROUND

static func is_blocked_cell(cell: Vector2i) -> bool:
	return get_tile_kind(cell) == KIND_BLOCK

static func is_world_position_walkable(world_position: Vector2, clearance: float = 0.0) -> bool:
	var samples := [
		Vector2.ZERO,
		Vector2(clearance, 0),
		Vector2(-clearance, 0),
		Vector2(0, clearance),
		Vector2(0, -clearance),
		Vector2(clearance, clearance),
		Vector2(-clearance, clearance),
		Vector2(clearance, -clearance),
		Vector2(-clearance, -clearance)
	]
	
	for offset in samples:
		if is_blocked_cell(world_to_cell(world_position + offset)):
			return false
	return true

static func get_atlas_cell(cell: Vector2i) -> Vector2i:
	return BLOCK_TILE if is_blocked_cell(cell) else GROUND_TILE

static func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(-MapData.MAP_SIZE + cell.x * GRID_SIZE, -MapData.MAP_SIZE + cell.y * GRID_SIZE)

static func cell_center_to_world(cell: Vector2i) -> Vector2:
	return cell_to_world(cell) + Vector2(GRID_SIZE, GRID_SIZE) * 0.5

static func world_to_cell(world_position: Vector2) -> Vector2i:
	var local_position := world_position - Vector2(-MapData.MAP_SIZE, -MapData.MAP_SIZE)
	return Vector2i(
		clampi(floori(local_position.x / GRID_SIZE), 0, GRID_COUNT - 1),
		clampi(floori(local_position.y / GRID_SIZE), 0, GRID_COUNT - 1)
	)

static func get_world_rect(cell: Vector2i) -> Rect2:
	return Rect2(cell_to_world(cell), Vector2(GRID_SIZE, GRID_SIZE))
