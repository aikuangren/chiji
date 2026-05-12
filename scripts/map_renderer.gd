extends Node2D
class_name MapRenderer

# 地图渲染器 - 绘制带噪声纹理的地图

const TILE_SIZE = 64  # 网格大小

var map_generator: MapGenerator
var region_textures: Dictionary = {}
var minimap_texture: ImageTexture

# 颜色缓存
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
	region_textures = map_generator.generate_all_region_textures()
	minimap_texture = map_generator.generate_minimap_texture()
	print("地图贴图生成完成!")

func _draw():
	_draw_regions()
	_draw_grid()

# 绘制各区域背景
func _draw_regions():
	var step = TILE_SIZE / 2  # 采样步进（32px）
	
	# 计算整个地图的边界
	var map_size = MapData.MAP_SIZE
	var min_x = -map_size
	var max_x = map_size
	var min_y = -map_size
	var max_y = map_size
	
	var y = min_y
	while y <= max_y:
		var x = min_x
		while x <= max_x:
			var color = _get_noise_color(x, y)
			var half_step = step / 2
			var rect = Rect2(x - half_step, y - half_step, step, step)
			draw_rect(rect, color, true)
			x += step
		y += step

# 获取带噪声和区域混合的颜色
func _get_noise_color(x: float, y: float) -> Color:
	# 获取该点的区域混合权重
	var weights = MapData.get_region_blend(x, y)
	
	if weights.is_empty():
		# 不在任何区域内，使用最近的区域颜色
		var region = MapData.get_region_at(x, y)
		var config = MapData.REGION_CONFIGS[region]
		var noise_val = _get_noise_at(x, y, region)
		return _blend_noise(config["base_color"], config["variance_color"], noise_val, region)
	
	# 多区域混合
	var final_color = Color(0, 0, 0, 0)
	var total_weight = 0.0
	
	for region_type in weights.keys():
		var weight = weights[region_type]
		var config = MapData.REGION_CONFIGS[region_type]
		var noise_val = _get_noise_at(x, y, region_type)
		var region_color = _blend_noise(config["base_color"], config["variance_color"], noise_val, region_type)
		
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

# 获取某点的噪声值
var _noise_cache: FastNoiseLite = null
func _get_noise_at(x: float, y: float, _region_type: int) -> float:
	if _noise_cache == null:
		_noise_cache = FastNoiseLite.new()
		_noise_cache.noise_type = FastNoiseLite.TYPE_SIMPLEX
		_noise_cache.seed = randi() % 1000
		_noise_cache.frequency = 0.03
		_noise_cache.fractal_octaves = 3
		_noise_cache.fractal_lacunarity = 2.0
		_noise_cache.fractal_gain = 0.5
	
	var val = _noise_cache.get_noise_2d(x * 0.5, y * 0.5) * 0.5 + 0.5
	return clampf(val, 0.0, 1.0)

# 应用噪声到颜色上
func _blend_noise(base: Color, variance: Color, noise_val: float, region_type: int) -> Color:
	match region_type:
		MapData.RegionType.FOREST:
			# 森林 - 深浅绿色变化，偶尔有枯叶色
			var r = base.r + variance.r * noise_val - 0.05
			var g = base.g + variance.g * noise_val * 1.2
			var b = base.b + variance.b * noise_val * 0.8
			if noise_val > 0.7:
				r += 0.03; g -= 0.02; b -= 0.02
			return Color(r, g, b, 1.0)
		
		MapData.RegionType.PLAINS:
			# 平原 - 均匀草地，偶尔有黄色
			var r = base.r + variance.r * noise_val * 0.8
			var g = base.g + variance.g * noise_val
			var b = base.b + variance.b * noise_val * 0.6
			if noise_val > 0.75:
				r += 0.08; g += 0.05; b -= 0.05
			return Color(r, g, b, 1.0)
		
		MapData.RegionType.CITY:
			# 城市废墟 - 灰调，有裂缝和阴影
			var r = base.r + variance.r * noise_val * 0.5
			var g = base.g + variance.g * noise_val * 0.5
			var b = base.b + variance.b * noise_val * 0.5
			if noise_val < 0.25 or noise_val > 0.8:
				var factor = 0.1 if noise_val < 0.25 else 0.15
				r -= factor; g -= factor; b -= factor
			return Color(r, g, b, 1.0)
		
		MapData.RegionType.DESERT:
			# 沙漠 - 黄褐色，有沙丘深浅变化
			var r = base.r + variance.r * noise_val
			var g = base.g + variance.g * noise_val * 0.8
			var b = base.b + variance.b * noise_val * 0.5
			if noise_val > 0.8:
				r -= 0.1; g -= 0.12; b -= 0.08
			return Color(r, g, b, 1.0)
	
	return base

# 绘制网格线
func _draw_grid():
	var map_size = MapData.MAP_SIZE
	var grid_color = Color(1, 1, 1, 0.12)
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

func get_player_region_type(player_pos: Vector2) -> MapData.RegionType:
	return MapData.get_region_at(player_pos.x, player_pos.y)
