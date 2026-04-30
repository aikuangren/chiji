class_name MapGenerator

# 程序化地图贴图生成器
# 使用 Noise 生成各区域的纹理

const TILE_SIZE = 64  # 网格大小
const TEXTURE_SIZE = 256  # 贴图像素尺寸

var _noise: FastNoiseLite
var _detail_noise: FastNoiseLite  # 用于细节纹理的噪声

func _init():
	_setup_noise()

func _setup_noise():
	# 主噪声 - 控制大面积纹理
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.seed = randi() % 1000
	_noise.frequency = 0.02
	_noise.fractal_octaves = 4
	_noise.fractal_lacunarity = 2.0
	_noise.fractal_gain = 0.5
	
	# 细节噪声 - 控制小面积变化
	_detail_noise = FastNoiseLite.new()
	_detail_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_detail_noise.seed = randi() % 1000
	_detail_noise.frequency = 0.08
	_detail_noise.fractal_octaves = 3
	_detail_noise.fractal_lacunarity = 2.0
	_detail_noise.fractal_gain = 0.3

# 生成单个区域的贴图
func generate_region_texture(region_type: MapData.RegionType) -> ImageTexture:
	var config = MapData.REGION_CONFIGS[region_type]
	var image = Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	
	for y in range(TEXTURE_SIZE):
		for x in range(TEXTURE_SIZE):
			# 归一化坐标到 [-1, 1]
			var nx = float(x) / TEXTURE_SIZE * 2.0 - 1.0
			var ny = float(y) / TEXTURE_SIZE * 2.0 - 1.0
			
			# 获取该点的噪声值
			var noise_val = _noise.get_noise_2d(nx * 50, ny * 50) * 0.5 + 0.5
			var detail_val = _detail_noise.get_noise_2d(nx * 100, ny * 100) * 0.5 + 0.5
			
			# 混合基础色和变化色
			var blended = _blend_region_colors(config, noise_val, detail_val, region_type)
			image.set_pixel(x, y, blended)
	
	var texture = ImageTexture.create_from_image(image)
	return texture

# 根据区域类型混合颜色
func _blend_region_colors(config: Dictionary, noise_val: float, detail_val: float, region_type: int) -> Color:
	var base = config["base_color"]
	var variance = config["variance_color"]
	
	# 组合噪声
	var combined = noise_val * 0.7 + detail_val * 0.3
	
	# 根据区域类型应用不同的颜色变化
	match region_type:
		MapData.RegionType.FOREST:
			# 森林 - 添加深浅绿色变化，偶尔有枯叶色
			var r = base.r + variance.r * combined - 0.05
			var g = base.g + variance.g * combined * 1.2  # 绿色通道稍亮
			var b = base.b + variance.b * combined * 0.8
			# 添加一点棕色（树枝/泥土）
			if combined > 0.7:
				r += 0.03
				g -= 0.02
				b -= 0.02
			return Color(r, g, b, 1.0)
		
		MapData.RegionType.PLAINS:
			# 平原 - 均匀的草地绿，偶尔有黄色野花
			var r = base.r + variance.r * combined * 0.8
			var g = base.g + variance.g * combined
			var b = base.b + variance.b * combined * 0.6
			# 随机黄色点缀
			if combined > 0.75:
				r += 0.08
				g += 0.05
				b -= 0.05
			return Color(r, g, b, 1.0)
		
		MapData.RegionType.CITY:
			# 城市废墟 - 灰调，偶尔有裂缝/深色
			var base_gray = base.r + base.g + base.b / 3.0
			var r = base.r + variance.r * combined * 0.5
			var g = base.g + variance.g * combined * 0.5
			var b = base.b + variance.b * combined * 0.5
			# 添加裂缝和阴影
			if combined < 0.25 or combined > 0.8:
				var factor = 0.1 if combined < 0.25 else 0.15
				r -= factor
				g -= factor
				b -= factor
			return Color(r, g, b, 1.0)
		
		MapData.RegionType.DESERT:
			# 沙漠 - 黄褐色调，有深浅沙丘
			var r = base.r + variance.r * combined
			var g = base.g + variance.g * combined * 0.8
			var b = base.b + variance.b * combined * 0.5
			# 添加深色斑点（岩石/阴影）
			if combined > 0.8:
				r -= 0.1
				g -= 0.12
				b -= 0.08
			return Color(r, g, b, 1.0)
	
	return base

# 生成所有区域的贴图
func generate_all_region_textures() -> Dictionary:
	var textures = {}
	for region_type in MapData.RegionType.values():
		textures[region_type] = generate_region_texture(region_type)
	return textures

# 获取某个位置的区域贴图 UV
func get_region_uv(world_pos: Vector2) -> Dictionary:
	# 计算在哪个区域
	var region = MapData.get_region_at(world_pos.x, world_pos.y)
	var config = MapData.REGION_CONFIGS[region]
	
	# 计算相对于区域中心的 UV
	var region_data = _get_region_center_and_radius(region)
	var center = Vector2(region_data[0], region_data[1])
	var radius = region_data[2]
	
	var local_pos = world_pos - center
	var uv = local_pos / (radius * 2.0) + Vector2(0.5, 0.5)
	
	return {
		"region_type": region,
		"texture": generate_region_texture(region),
		"uv": uv,
		"config": config
	}

func _get_region_center_and_radius(region_type: MapData.RegionType) -> Array:
	for region in MapData.REGION_LAYOUT:
		if region[3] == region_type:
			return [region[0], region[1], region[2]]
	return [0, 0, 400]

# 生成小地图用的缩略图
func generate_minimap_texture() -> ImageTexture:
	var size = 512
	var image = Image.create(size, size, false, Image.FORMAT_RGB8)
	var scale = float(size) / (MapData.MAP_SIZE * 2)
	var offset = MapData.MAP_SIZE
	
	for y in range(size):
		for x in range(size):
			var world_x = (x - size/2) / scale
			var world_y = (y - size/2) / scale
			var region = MapData.get_region_at(world_x, world_y)
			var config = MapData.REGION_CONFIGS[region]
			image.set_pixel(x, y, config["base_color"])
	
	var texture = ImageTexture.create_from_image(image)
	return texture
