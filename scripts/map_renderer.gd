extends Node2D
class_name MapRenderer

# 地图渲染器 - 绘制分区域纹理地图

const TILE_SIZE = 64  # 网格大小

var map_generator: MapGenerator
var region_textures: Dictionary = {}
var minimap_texture: ImageTexture

# 颜色缓存 (用于性能)
var _region_base_colors = {
	MapData.RegionType.FOREST: Color(0.15, 0.35, 0.15),
	MapData.RegionType.PLAINS: Color(0.45, 0.55, 0.3),
	MapData.RegionType.CITY: Color(0.35, 0.33, 0.32),
	MapData.RegionType.DESERT: Color(0.65, 0.55, 0.35)
}

# 区域名称
var _region_names = {
	MapData.RegionType.FOREST: "森林",
	MapData.RegionType.PLAINS: "平原",
	MapData.RegionType.CITY: "城市废墟",
	MapData.RegionType.DESERT: "沙漠"
}

func _ready():
	map_generator = MapGenerator.new()
	# 生成所有区域的贴图
	region_textures = map_generator.generate_all_region_textures()
	minimap_texture = map_generator.generate_minimap_texture()
	print("地图贴图生成完成!")

func _draw():
	# 绘制每个区域
	_draw_regions()
	# 绘制网格线
	_draw_grid()

# 绘制各区域背景
func _draw_regions():
	# 遍历每个区域
	for region in MapData.REGION_LAYOUT:
		var center_x = region[0]
		var center_y = region[1]
		var radius = region[2]
		var region_type = region[3]
		
		# 获取区域配置
		var config = MapData.REGION_CONFIGS[region_type]
		var base_color = config["base_color"]
		
		# 绘制圆形区域（带边缘过渡）
		_draw_filled_circle_with_blend(center_x, center_y, radius, base_color, region_type)

# 带边缘过渡的圆形绘制
func _draw_filled_circle_with_blend(cx: float, cy: float, radius: float, base_color: Color, region_type: int):
	var step = TILE_SIZE / 2  # 采样步进
	
	# 计算 bounding box
	var min_x = cx - radius - step
	var max_x = cx + radius + step
	var min_y = cy - radius - step
	var max_y = cy + radius + step
	
	# 遍历绘制
	var y = min_y
	while y <= max_y:
		var x = min_x
		while x <= max_x:
			var dx = x - cx
			var dy = y - cy
			var dist = sqrt(dx * dx + dy * dy)
			
			if dist <= radius + step:
				# 计算颜色（区域边缘有过渡）
				var color = _get_blended_color(x, y, region_type, base_color)
				
				# 绘制方块
				var half_step = step / 2
				var alpha = 1.0
				
				# 边缘抗锯齿
				if dist > radius - step and dist <= radius + step:
					alpha = 1.0 - (dist - (radius - step)) / (step * 2)
					alpha = clampf(alpha, 0.0, 1.0)
				
				if alpha > 0.01:
					var adjusted_color = Color(color.r, color.g, color.b, alpha)
					_draw_textured_tile(x - half_step, y - half_step, adjusted_color)
			
			x += step
		y += step

# 获取混合后的颜色
func _get_blended_color(x: float, y: float, primary_region: int, primary_color: Color) -> Color:
	var weights = MapData.get_region_blend(x, y)
	
	if weights.is_empty():
		return _region_base_colors[MapData.RegionType.PLAINS]
	
	# 如果只有一个区域主导，直接返回
	if weights.size() == 1:
		return primary_color
	
	# 多区域混合
	var final_color = Color(0, 0, 0, 0)
	var total_weight = 0.0
	
	for region_type in weights.keys():
		var weight = weights[region_type]
		var region_color = _region_base_colors[region_type]
		final_color.r += region_color.r * weight
		final_color.g += region_color.g * weight
		final_color.b += region_color.b * weight
		final_color.a += weight
		total_weight += weight
	
	if total_weight > 0:
		final_color.r /= total_weight
		final_color.g /= total_weight
		final_color.b /= total_weight
	
	return final_color

# 绘制单个贴片
func _draw_textured_tile(x: float, y: float, color: Color):
	var size = TILE_SIZE / 2
	var rect = Rect2(x - size, y - size, size * 2, size * 2)
	draw_rect(rect, color, true)

# 绘制网格线
func _draw_grid():
	var map_size = MapData.MAP_SIZE
	var grid_color = Color(1, 1, 1, 0.15)
	var y = -map_size
	while y <= map_size:
		draw_line(Vector2(-map_size, y), Vector2(map_size, y), grid_color, 1.0)
		y += TILE_SIZE
	var x = -map_size
	while x <= map_size:
		draw_line(Vector2(x, -map_size), Vector2(x, map_size), grid_color, 1.0)
		x += TILE_SIZE

# 获取玩家当前所在区域
func get_player_region(player_pos: Vector2) -> String:
	var region_type = MapData.get_region_at(player_pos.x, player_pos.y)
	return _region_names[region_type]

# 获取玩家当前区域类型
func get_player_region_type(player_pos: Vector2) -> MapData.RegionType:
	return MapData.get_region_at(player_pos.x, player_pos.y)
