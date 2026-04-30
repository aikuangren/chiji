class_name SupplyData

# 增益道具类型
enum ItemType {
	HEAL,           # 治疗 - 回复20%血量
	SHOTGUN,        # 散弹 - 20秒散弹效果
	# 后续扩展位置
}

# 道具显示配置
const ITEM_CONFIGS = {
	ItemType.HEAL: {
		"name": "治疗药包",
		"desc": "回复20%生命值",
		"color": Color(0.2, 0.8, 0.2, 1.0),
		"glow_color": Color(0.2, 0.8, 0.2, 0.4),
		"icon": "+",
		"size": Vector2(24, 24),
		"spawn_weight": 40,
	},
	ItemType.SHOTGUN: {
		"name": "散弹枪",
		"desc": "20秒散弹模式",
		"color": Color(0.2, 0.5, 1.0, 1.0),
		"glow_color": Color(0.2, 0.5, 1.0, 0.4),
		"icon": "*",
		"size": Vector2(26, 26),
		"spawn_weight": 30,
	},
}

# 区域道具密度配置
const REGION_SPAWN_DENSITY = {
	MapData.RegionType.FOREST: 0.020,
	MapData.RegionType.PLAINS: 0.025,
	MapData.RegionType.CITY: 0.030,
	MapData.RegionType.DESERT: 0.012,
}

# 根据权重随机选择道具类型
static func random_item_type() -> ItemType:
	var total_weight = 0
	for type in ITEM_CONFIGS:
		total_weight += ITEM_CONFIGS[type]["spawn_weight"]
	
	var rand_val = randf() * total_weight
	var cumulative = 0
	
	for type in ITEM_CONFIGS:
		cumulative += ITEM_CONFIGS[type]["spawn_weight"]
		if rand_val <= cumulative:
			return type
	
	return ItemType.HEAL

# 获取道具配置
static func get_config(item_type: ItemType) -> Dictionary:
	return ITEM_CONFIGS[item_type]
