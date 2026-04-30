extends Control

class_name Minimap

# 小地图尺寸
const MINIMAP_SIZE = 180
const MAP_SIZE = 2000  # 地图范围 ±2000

# 标记颜色
const PLAYER_COLOR = Color(1.0, 1.0, 1.0)      # 白色 - 玩家
const ENEMY_SHOOTER_COLOR = Color(1.0, 0.2, 0.2)  # 红色 - 射击怪
const ENEMY_MELEE_COLOR = Color(1.0, 0.9, 0.1)    # 黄色 - 自爆怪
const ITEM_COLOR = Color(0.2, 0.8, 0.2)          # 绿色 - 道具
const BG_COLOR = Color(0.1, 0.12, 0.14, 0.85)
const GRID_COLOR = Color(1, 1, 1, 0.06)

# 标记大小
const DOT_PLAYER = 4
const DOT_ENEMY = 2
const DOT_ITEM = 2

var _draw_player_pos: Vector2
var _draw_enemies: Array
var _draw_items: Array

func _ready():
	custom_minimum_size = Vector2(MINIMAP_SIZE, MINIMAP_SIZE)
	size = Vector2(MINIMAP_SIZE, MINIMAP_SIZE)
	position = Vector2(0, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

# 将世界坐标映射到小地图坐标
func _world_to_minimap(world_pos: Vector2) -> Vector2:
	var mx = (world_pos.x / MAP_SIZE + 1.0) * 0.5 * MINIMAP_SIZE
	var my = (world_pos.y / MAP_SIZE + 1.0) * 0.5 * MINIMAP_SIZE
	mx = clamp(mx, 0, MINIMAP_SIZE)
	my = clamp(my, 0, MINIMAP_SIZE)
	return Vector2(mx, my)

# 更新小地图标记
func update_markers(player_pos: Vector2, enemies: Array, items: Array):
	_draw_player_pos = player_pos
	_draw_enemies = enemies
	_draw_items = items
	queue_redraw()

func _draw():
	var rect = Rect2(Vector2.ZERO, Vector2(MINIMAP_SIZE, MINIMAP_SIZE))
	# 背景
	draw_rect(rect, BG_COLOR)
	# 边框
	draw_rect(rect, Color(1, 1, 1, 0.2), false, 1.0)
	
	# 网格线
	var step = 40.0
	var x = step
	while x < MINIMAP_SIZE:
		draw_line(Vector2(x, 0), Vector2(x, MINIMAP_SIZE), GRID_COLOR)
		x += step
	var y = step
	while y < MINIMAP_SIZE:
		draw_line(Vector2(0, y), Vector2(MINIMAP_SIZE, y), GRID_COLOR)
		y += step
	
	# 绘制道具标记
	for item in _draw_items:
		if not is_instance_valid(item):
			continue
		var pos = _world_to_minimap(item.position)
		draw_circle(pos, DOT_ITEM, ITEM_COLOR)
	
	# 绘制敌人标记
	for enemy in _draw_enemies:
		if not is_instance_valid(enemy):
			continue
		var pos = _world_to_minimap(enemy.position)
		var color = ENEMY_SHOOTER_COLOR if enemy.enemy_type == Enemy.Type.SHOOTER else ENEMY_MELEE_COLOR
		draw_circle(pos, DOT_ENEMY, color)
	
	# 绘制玩家标记（最上层）
	var p = _world_to_minimap(_draw_player_pos)
	var s = DOT_PLAYER
	# 玩家用菱形
	var diamond = PackedVector2Array([
		p + Vector2(0, -s),
		p + Vector2(s, 0),
		p + Vector2(0, s),
		p + Vector2(-s, 0)
	])
	draw_colored_polygon(diamond, PLAYER_COLOR)
	# 白色光圈
	draw_arc(p, DOT_PLAYER + 2, 0, TAU, 12, Color(1, 1, 1, 0.5), 1.0)
