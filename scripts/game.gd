extends Node2D

const RESULT_POPUP = preload("res://scenes/result_popup.tscn")

@onready var map_renderer: Node2D = $MapRenderer
@onready var player: CharacterBody2D = $Player
@onready var obstacles: Node2D = $Obstacles
@onready var supplies: Node2D = $Supplies
@onready var enemies_node: Node2D = $Enemies
@onready var bullets_node: Node2D = $Bullets

var obstacle_spawner = ObstacleSpawner.new()
var supply_spawner = SupplySpawner.new()
var enemy_spawner = EnemySpawner.new()

@onready var region_label: Label = $CanvasLayer/RegionLabel
@onready var hint_label: Label = $CanvasLayer/HintLabel
@onready var coords_label: Label = $CanvasLayer/CoordsLabel
@onready var buff_label: Label = $CanvasLayer/BuffLabel
@onready var minimap: Control = $CanvasLayer/MinimapContainer/Minimap
@onready var level_label: Label = $CanvasLayer/LevelLabel

# 统计信息
var kill_shooter: int = 0
var kill_melee: int = 0
var total_shooter: int = 0
var total_melee: int = 0
var start_time: float = 0.0
var game_over: bool = false
var game_initialized: bool = false

# 当前关卡
var current_level: int = 1
var level_config: Dictionary = {}

func _ready():
	randomize()
	
	# 读取当前关卡
	current_level = LevelManager.get_current_level()
	level_config = LevelManager.get_level_config(current_level)
	level_label.text = "关卡-%d" % current_level
	
	await get_tree().create_timer(0.5).timeout
	
	player.position = Vector2(0, 0)
	
	var region = MapData.get_region_at(player.position.x, player.position.y)
	obstacle_spawner.spawn_obstacles(obstacles, player.position, region)
	
	var item_count = level_config["item_count"]
	var crates = supply_spawner.spawn_supplies(item_count)
	for crate in crates:
		supplies.add_child(crate)
	
	# 生成所有区域的敌人
	enemy_spawner.spawn_all_regions(enemies_node, player.position)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	for enemy in enemy_spawner.get_enemies():
		if is_instance_valid(enemy):
			enemy.enemy_killed.connect(_on_enemy_killed)
			# 设置关卡配置的血量
			enemy.health = level_config["enemy_health"]
			enemy.health_bar.max_value = level_config["enemy_health"]
			enemy.health_bar.value = level_config["enemy_health"]
			match enemy.enemy_type:
				Enemy.Type.SHOOTER:
					total_shooter += 1
				Enemy.Type.MELEE:
					total_melee += 1
	
	player.set_bullet_container(bullets_node)
	
	player.player_died.connect(_on_player_died)
	
	start_time = Time.get_ticks_msec()
	
	_update_ui()
	
	await get_tree().create_timer(0.5).timeout
	start_time = Time.get_ticks_msec()
	game_initialized = true

func _process(_delta: float):
	if game_over:
		return
	
	_update_ui()
	_check_player_death()
	_check_nearest_supply()
	_check_victory()

func _update_ui():
	var region = MapData.get_region_at(player.position.x, player.position.y)
	var region_name = MapData.REGION_CONFIGS[region]["name"]
	
	var alive_shooter = total_shooter - kill_shooter
	var alive_melee = total_melee - kill_melee
	var alive_total = alive_shooter + alive_melee
	
	region_label.text = "%s | 剩余敌人 %d" % [region_name, alive_total]
	coords_label.text = "射击: %d  自爆: %d" % [alive_shooter, alive_melee]
	
	var buff_text = player.get_buff_status()
	if buff_text != "":
		buff_label.text = buff_text
		buff_label.visible = true
	else:
		buff_label.visible = false
	
	var nearest = supply_spawner.get_nearest_item(player.position)
	if nearest != null:
		var dist = player.position.distance_to(nearest.position)
		if dist < 80:
			hint_label.text = "按 E 拾取道具"
		else:
			hint_label.text = "按 空格 打开卡牌游戏 | O射击 | K近战"
	else:
		hint_label.text = "按 空格 打开卡牌游戏 | O射击 | K近战"
	
	_update_minimap()

func _update_minimap():
	var all_enemies = enemy_spawner.get_enemies()
	var alive_enemies: Array = []
	for e in all_enemies:
		if is_instance_valid(e):
			alive_enemies.append(e)
	
	var all_items = supply_spawner.spawned_items
	var alive_items: Array = []
	for item in all_items:
		if is_instance_valid(item):
			alive_items.append(item)
	
	minimap.update_markers(player.position, alive_enemies, alive_items)

func _on_enemy_killed(enemy_type: int):
	match enemy_type:
		Enemy.Type.SHOOTER:
			kill_shooter += 1
		Enemy.Type.MELEE:
			kill_melee += 1

func _check_player_death():
	if player.health <= 0 and not game_over:
		game_over = true
		_show_result(ResultPopup.Result.DEFEAT)

func _check_victory():
	if game_over or not game_initialized:
		return
	
	var alive_shooter = total_shooter - kill_shooter
	var alive_melee = total_melee - kill_melee
	
	if alive_shooter <= 0 and alive_melee <= 0:
		# 通关！保存记录
		LevelManager.complete_level(current_level)
		game_over = true
		_show_result(ResultPopup.Result.VICTORY)

func _show_result(result: ResultPopup.Result):
	player.set_process(false)
	player.set_physics_process(false)
	
	var popup = RESULT_POPUP.instantiate()
	add_child(popup)
	
	var elapsed = (Time.get_ticks_msec() - start_time) / 1000.0
	var total_kills = kill_shooter + kill_melee
	popup.show_result(result, total_kills, elapsed, current_level)

func _on_player_died():
	pass

func _check_nearest_supply():
	if Input.is_action_just_pressed("interact"):
		var nearest = supply_spawner.get_nearest_item(player.position)
		if nearest != null and is_instance_valid(nearest) and player.position.distance_to(nearest.position) < 80:
			var item_type = nearest.collect()
			supply_spawner.spawned_items.erase(nearest)
			var effect_text = player.apply_item_effect(item_type)
			hint_label.text = effect_text
			await get_tree().create_timer(2.0).timeout
			hint_label.text = ""
	
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/card_game/card_game_main.tscn")
