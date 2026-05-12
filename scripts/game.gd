extends Node2D

const RESULT_POPUP = preload("res://scenes/result_popup.tscn")

@onready var map_renderer: Node2D = $MapRenderer
@onready var player: CharacterBody2D = $Player
@onready var obstacles: Node2D = $Obstacles
@onready var supplies: Node2D = $Supplies
@onready var enemies_node: Node2D = $Enemies
@onready var bullets_node: Node2D = $Bullets
@onready var map_boundary: Node2D = $MapBoundary

var obstacle_spawner = ObstacleSpawner.new()
var supply_spawner = SupplySpawner.new()
var enemy_spawner = EnemySpawner.new()

@onready var hint_label: Label = $CanvasLayer/HintLabel
@onready var buff_label: Label = $CanvasLayer/BuffLabel
@onready var minimap: Control = $CanvasLayer/MinimapContainer/Minimap
@onready var level_label: Label = $CanvasLayer/LevelLabel
@onready var shooter_label: Label = $CanvasLayer/EnemyCountPanel/VBoxContainer/ShooterLabel
@onready var melee_label: Label = $CanvasLayer/EnemyCountPanel/VBoxContainer/MeleeLabel
@onready var exit_button: Button = $CanvasLayer/ExitButton

var kill_shooter: int = 0
var kill_melee: int = 0
var total_shooter: int = 0
var total_melee: int = 0
var start_time: float = 0.0
var game_over: bool = false
var game_initialized: bool = false

var current_level: int = 1
var level_config: Dictionary = {}

func _ready():
	randomize()
	add_to_group("game")
	
	current_level = LevelManager.get_current_level()
	level_config = LevelManager.get_level_config(current_level)
	level_label.text = "关卡-%d" % current_level
	
	$CanvasLayer/DamageOverlay.add_to_group("damage_overlay")
	
	# 生成地图边界墙
	_create_map_boundary()
	
	exit_button.pressed.connect(_on_exit)
	
	await get_tree().create_timer(0.5).timeout
	
	player.position = Vector2(0, 0)
	
	var region = MapData.get_region_at(player.position.x, player.position.y)
	obstacle_spawner.spawn_obstacles(obstacles, player.position, region)
	
	var item_count = level_config["item_count"]
	var crates = supply_spawner.spawn_supplies(item_count)
	for crate in crates:
		supplies.add_child(crate)
	
	enemy_spawner.spawn_all_regions(enemies_node, player.position)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	for enemy in enemy_spawner.get_enemies():
		if is_instance_valid(enemy):
			enemy.enemy_killed.connect(_on_enemy_killed)
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
	
	_update_fog()
	_update_ui()
	_check_player_death()
	_check_victory()

func _update_ui():
	var alive_shooter = total_shooter - kill_shooter
	var alive_melee = total_melee - kill_melee
	
	shooter_label.text = "● 射击怪: %d" % alive_shooter
	melee_label.text = "● 自爆怪: %d" % alive_melee
	
	var buff_text = player.get_buff_status()
	if buff_text != "":
		buff_label.text = buff_text
		buff_label.visible = true
	else:
		buff_label.visible = false
	
	_update_minimap()

func show_hint(text: String):
	hint_label.text = text
	await get_tree().create_timer(2.0).timeout
	if hint_label.text == text:
		hint_label.text = "WASD移动 | O射击 | K近战"

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

func _on_exit():
	var dialog = ConfirmationDialog.new()
	dialog.title = "退出游戏"
	dialog.dialog_text = "确定要退出当前关卡吗？"
	dialog.ok_button_text = "确定"
	dialog.cancel_button_text = "取消"
	add_child(dialog)
	dialog.popup_centered()
	
	await dialog.confirmed
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# 创建地图边界碰撞墙
func _create_map_boundary():
	var m = MapData.MAP_SIZE
	var wall_thickness = 64  # 墙厚度
	var wall_color = Color(0.5, 0.2, 0.1, 0.6)  # 棕色半透明显示边界
	
	# 四面墙的配置：[position_x, position_y, size_x, size_y]
	var walls = [
		# 上墙 (y = -m)
		[0, -m - wall_thickness/2, m * 2 + wall_thickness * 2, wall_thickness],
		# 下墙 (y = m)
		[0, m + wall_thickness/2, m * 2 + wall_thickness * 2, wall_thickness],
		# 左墙 (x = -m)
		[-m - wall_thickness/2, 0, wall_thickness, m * 2],
		# 右墙 (x = m)
		[m + wall_thickness/2, 0, wall_thickness, m * 2],
	]
	
	for wall in walls:
		var body = StaticBody2D.new()
		body.collision_layer = 2  # terrain层，与玩家collision_mask匹配
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(wall[2], wall[3])
		shape.shape = rect
		body.position = Vector2(wall[0], wall[1])
		body.add_child(shape)
		map_boundary.add_child(body)

# 更新战争迷雾 - 传入玩家屏幕位置到着色器
func _update_fog():
	var fog = $CanvasLayer/Fog
	if fog and fog.material is ShaderMaterial:
		var camera = get_viewport().get_camera_2d()
		if camera and is_instance_valid(player):
			var screen_pos = camera.unproject_position(player.global_position)
			fog.material.set_shader_parameter("player_pos", screen_pos)
