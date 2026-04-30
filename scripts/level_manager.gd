class_name LevelManager

# 关卡记录文件路径
const SAVE_PATH = "user://level_save.cfg"

# 默认关卡数
const MAX_LEVEL = 99

# 关卡间传递的暂存值（不保存到文件，仅本次运行有效）
static var next_level_override: int = 0

# 读取当前关卡号（最近未通关的关卡）
static func get_current_level() -> int:
	if next_level_override > 0:
		var result = next_level_override
		next_level_override = 0
		return result
	
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return 1
	var cleared = config.get_value("progress", "cleared_level", 0)
	return cleared + 1

# 通关当前关卡，保存记录
static func complete_level(level: int):
	var config = ConfigFile.new()
	config.load(SAVE_PATH)
	
	var current_cleared = config.get_value("progress", "cleared_level", 0)
	if level > current_cleared:
		config.set_value("progress", "cleared_level", level)
	config.save(SAVE_PATH)

# 标记下一关（用于胜利后跳转）
static func go_to_next_level(level: int):
	next_level_override = level + 1

# 重置所有关卡记录
static func reset_progress():
	var config = ConfigFile.new()
	config.set_value("progress", "cleared_level", 0)
	config.save(SAVE_PATH)

# 根据关卡号获取关卡配置（后续可扩展难度参数）
static func get_level_config(level: int) -> Dictionary:
	# 基础配置
	var config = {
		"enemy_count_per_region": 5,
		"item_count": 6,
		"enemy_health": 50.0,
	}
	
	# 每5关提升一次难度
	var tier = (level - 1) / 5 + 1
	config["enemy_count_per_region"] = 4 + tier  # 5,6,7...
	config["enemy_health"] = 50.0 + (tier - 1) * 10  # 50,60,70...
	config["item_count"] = min(4 + tier, 10)  # 5,6,7...(最多10)
	
	return config
