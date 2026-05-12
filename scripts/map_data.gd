class_name MapData

# 地图区域类型枚举
enum RegionType {
	FOREST,      # 森林 - 深绿色，树木纹理
	PLAINS,      # 平原 - 浅绿色，草地
	CITY,        # 城市废墟 - 灰色，碎石纹理  
	DESERT       # 沙漠 - 黄褐色，沙地纹理
}

# 区域配置
const REGION_CONFIGS = {
	RegionType.FOREST: {
		"name": "森林",
		"base_color": Color(0.15, 0.35, 0.15),
		"variance_color": Color(0.08, 0.15, 0.08),
		"pattern_scale": 0.15,
		"obstacle_color": Color(0.25, 0.18, 0.1),
		"obstacle_density": 0.08,
		"obstacle_size": Vector2(40, 40)
	},
	RegionType.PLAINS: {
		"name": "平原",
		"base_color": Color(0.45, 0.55, 0.3),
		"variance_color": Color(0.1, 0.12, 0.05),
		"pattern_scale": 0.08,
		"obstacle_color": Color(0.3, 0.25, 0.15),
		"obstacle_density": 0.02,
		"obstacle_size": Vector2(25, 25)
	},
	RegionType.CITY: {
		"name": "城市废墟",
		"base_color": Color(0.35, 0.33, 0.32),
		"variance_color": Color(0.08, 0.08, 0.08),
		"pattern_scale": 0.25,
		"obstacle_color": Color(0.25, 0.22, 0.2),
		"obstacle_density": 0.15,
		"obstacle_size": Vector2(50, 50)
	},
	RegionType.DESERT: {
		"name": "沙漠",
		"base_color": Color(0.65, 0.55, 0.35),
		"variance_color": Color(0.1, 0.08, 0.05),
		"pattern_scale": 0.12,
		"obstacle_color": Color(0.5, 0.4, 0.25),
		"obstacle_density": 0.01,
		"obstacle_size": Vector2(30, 30)
	}
}

# 地图配置
const MAP_SIZE: int = 2000
const TILE_SIZE: int = 64
const TEXTURE_SIZE: int = 512  # 每个区域生成的贴图尺寸

# 区域布局 (center_x, center_y, radius, type)
# 半径单位是像素
const REGION_LAYOUT = [
	[-600, -400, 400, RegionType.FOREST],   # 左上 - 森林
	[500, -450, 350, RegionType.PLAINS],     # 右上 - 平原
	[-500, 500, 380, RegionType.CITY],       # 左下 - 城市废墟
	[550, 450, 400, RegionType.DESERT]        # 右下 - 沙漠
]

# 获取某个位置的区域类型
static func get_region_at(x: float, y: float) -> RegionType:
	for region in REGION_LAYOUT:
		var dx = x - region[0]
		var dy = y - region[1]
		var dist = sqrt(dx * dx + dy * dy)
		if dist < region[2]:
			return region[3]
	# 边界区域默认为平原
	return RegionType.PLAINS

# 获取区域的过渡权重 (用于区域边缘混合)
# 所有区域参与混合，距离越近权重越大，实现平滑过渡
static func get_region_blend(x: float, y: float) -> Dictionary:
	var total_weight: float = 0.0
	var weights: Dictionary = {}
	
	for region in REGION_LAYOUT:
		var region_type = region[3]
		var dx = x - region[0]
		var dy = y - region[1]
		var dist = sqrt(dx * dx + dy * dy)
		var radius = region[2]
		var falloff = radius * 1.4  # 过渡范围延伸到区域外40%
		
		# 使用 smoothstep 计算权重
		if dist < falloff:
			var weight = smoothstep(falloff, 0.0, dist)  # 中心权重最大，向外递减
			weights[region_type] = weight
			total_weight += weight
	
	# 归一化
	if total_weight > 0:
		for key in weights:
			weights[key] /= total_weight
	
	return weights

# 平滑插值函数
static func smoothstep(edge0: float, edge1: float, x: float) -> float:
	var t = clampf((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
