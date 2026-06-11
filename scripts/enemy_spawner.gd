extends Node

class_name EnemySpawner

var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var enemies: Array[Enemy] = []

const ENEMY_COUNT_PER_REGION = 5  # 每个区域5个敌人
const ENEMY_CLEARANCE = 48.0
const MIN_DISTANCE_FROM_PLAYER = 180.0
const MIN_DISTANCE_BETWEEN_ENEMIES = 120.0
const MAX_SPAWN_ATTEMPTS_PER_ENEMY = 40

func _init():
	# 确保enemy场景存在
	_create_enemy_scene_if_needed()

func _create_enemy_scene_if_needed():
	# 创建enemy场景文件
	var scene_path = "res://scenes/enemy.tscn"
	var dir = DirAccess.open("res://scenes")
	if dir:
		if not dir.file_exists("enemy.tscn"):
			_create_enemy_scene()

func _create_enemy_scene():
	# 创建一个基本的enemy场景
	var tscn_content = """[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/enemy.gd" id="1_enemy"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_1"]
size = Vector2(24, 24)

[node name="Enemy" type="CharacterBody2D"]
collision_layer = 4
collision_mask = 3
script = ExtResource("1_enemy")

[node name="Shadow" type="ColorRect" parent="."]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -14.0
offset_top = 0.0
offset_right = 14.0
offset_bottom = 8.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.1, 0.05, 0.05, 0.6)

[node name="Sprite" type="ColorRect" parent="."]
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -12.0
offset_top = -12.0
offset_right = 12.0
offset_bottom = 12.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.2, 0.2, 0.2, 1)

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_1")
"""
	var scene_path = "res://scenes/enemy.tscn"
	var file = FileAccess.open(scene_path, FileAccess.WRITE)
	if file:
		file.store_string(tscn_content)
		file.close()

func spawn_enemies(container: Node2D, player_pos: Vector2, region: int) -> Array[Enemy]:
	var region_data = _get_region_center_and_radius(region)
	var center = Vector2(region_data[0], region_data[1])
	var radius = region_data[2]
	
	for i in range(ENEMY_COUNT_PER_REGION):
		var spawn_pos = _find_valid_spawn_position(center, radius, player_pos)
		if spawn_pos == Vector2.INF:
			continue
		
		var enemy = enemy_scene.instantiate()
		enemy.position = spawn_pos
		container.add_child(enemy)
		enemies.append(enemy)
	
	return enemies

func spawn_all_regions(container: Node2D, player_pos: Vector2) -> Array[Enemy]:
	# 为每个区域生成敌人
	for region in MapData.RegionType.values():
		spawn_enemies(container, player_pos, region)
	return enemies

func get_enemies() -> Array[Enemy]:
	return enemies

func remove_enemy(enemy: Enemy) -> void:
	enemies.erase(enemy)

func _get_region_center_and_radius(region_type: int) -> Array:
	for region in MapData.REGION_LAYOUT:
		if region[3] == region_type:
			return [region[0], region[1], region[2]]
	return [0, 0, 400]

func _find_valid_spawn_position(center: Vector2, radius: float, player_pos: Vector2) -> Vector2:
	for attempt in range(MAX_SPAWN_ATTEMPTS_PER_ENEMY):
		var angle = randf() * TAU
		var distance = randf() * radius * 0.8
		var spawn_pos = center + Vector2(cos(angle), sin(angle)) * distance
		
		if not _is_spawn_position_valid(spawn_pos, player_pos):
			continue
		
		return spawn_pos
	
	return Vector2.INF

func _is_spawn_position_valid(spawn_pos: Vector2, player_pos: Vector2) -> bool:
	if spawn_pos.distance_to(player_pos) < MIN_DISTANCE_FROM_PLAYER:
		return false
	
	if not MapTileData.is_world_position_walkable(spawn_pos, ENEMY_CLEARANCE):
		return false
	
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.position.distance_to(spawn_pos) < MIN_DISTANCE_BETWEEN_ENEMIES:
			return false
	
	return true
