extends CharacterBody2D

class_name Player

signal player_died()

const SPEED = 300.0
const MAX_HEALTH = 100.0

# 攻击相关
const BULLET_SCENE = preload("res://scenes/bullet.tscn")
const SHOTGUN_BULLET_SCENE = preload("res://scenes/shotgun_bullet.tscn")
const MELEE_SCENE = preload("res://scenes/melee_attack.tscn")
const SHOOT_COOLDOWN = 0.2
const MELEE_COOLDOWN = 0.4

# 散弹参数
const SHOTGUN_SPREAD = 15.0
const SHOTGUN_PELLETS = 5
const SHOTGUN_COOLDOWN = 0.4
const SHOTGUN_DURATION = 20.0

const SCREEN_VIEW_RANGE = 400.0
# 屏幕视野矩形（相机zoom=2，窗口1280x720）
# 实际可见：从屏幕中心到边缘宽320、高180
# 加上缓冲区后：宽350、高210
const VIEW_WIDTH = 350.0
const VIEW_HEIGHT = 210.0
const PLAYER_RADIUS = 12.0  # 主角圆形半径
const ARROW_LENGTH = 18.0   # 箭头长度
const ARROW_HEAD_SIZE = 6.0 # 箭头头部大小

var health: float = MAX_HEALTH
var shoot_cooldown: float = 0.0
var melee_cooldown: float = 0.0

var is_shotgun_mode: bool = false
var shotgun_timer: float = 0.0

var bullet_container: Node2D
var melee_attack: MeleeAttack

# 朝向方向 - 箭头指向的方向
# 由 WASD 或自动瞄准更新
var facing_dir: Vector2 = Vector2.RIGHT

@onready var health_bar: ProgressBar = $HealthBar

func _ready():
	add_to_group("player")
	
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	health_bar.visible = true
	
	queue_redraw()

func _draw():
	# === 视野范围指示（金色矩形框）===
	var view_rect = Rect2(-VIEW_WIDTH, -VIEW_HEIGHT, VIEW_WIDTH * 2, VIEW_HEIGHT * 2)
	draw_rect(view_rect, Color(1.0, 0.8, 0.0, 0.06))  # 半透明填充
	# 矩形边框
	draw_rect(view_rect, Color(1.0, 0.8, 0.0, 0.35), false, 1.5)
	
	# === 主角圆形身体 ===
	var body_color = Color(0.9, 0.2, 0.2, 1.0)  # 红色主体
	var body_outline = Color(0.7, 0.1, 0.1, 1.0) # 深红色边框
	draw_circle(Vector2.ZERO, PLAYER_RADIUS, body_color)
	draw_arc(Vector2.ZERO, PLAYER_RADIUS, 0, TAU, 24, body_outline, 2.0)
	
	# === 方向箭头 ===
	var arrow_color = Color(1.0, 1.0, 1.0, 0.9)  # 白色箭头
	var arrow_tip = facing_dir * ARROW_LENGTH
	var arrow_base = facing_dir * (PLAYER_RADIUS + 2)
	
	# 箭杆
	draw_line(arrow_base, arrow_tip, arrow_color, 3.0)
	
	# 箭头（三角形头部）
	var head_angle = facing_dir.angle()
	var left = arrow_tip + Vector2.from_angle(head_angle + 2.5) * ARROW_HEAD_SIZE
	var right = arrow_tip + Vector2.from_angle(head_angle - 2.5) * ARROW_HEAD_SIZE
	var head_points = PackedVector2Array([arrow_tip, left, right])
	draw_colored_polygon(head_points, arrow_color)

func _physics_process(delta):
	var move_dir = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_dir.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_dir.x += 1
	
	if move_dir.length() > 0:
		move_dir = move_dir.normalized()
		# WASD 移动时，箭头指向移动方向（优先级最高）
		facing_dir = move_dir
	else:
		# 停下来时，检查屏幕内是否有敌人进行自动瞄准
		var target_dir = _get_auto_aim_direction()
		if target_dir != Vector2.ZERO:
			facing_dir = target_dir
		# 无敌人 → facing_dir 保持不变
	
	velocity = move_dir * SPEED
	move_and_slide()
	
	shoot_cooldown = maxf(shoot_cooldown - delta, 0.0)
	melee_cooldown = maxf(melee_cooldown - delta, 0.0)
	
	_update_shotgun_mode(delta)
	
	# 刷新绘制（箭头方向变化）
	queue_redraw()
	
	_handle_attack_input()

# 检查屏幕视野范围内是否有敌人
func _has_enemy_in_range() -> bool:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if _is_in_view(enemy.global_position):
			return true
	return false

# 判断敌人是否在屏幕视野范围内
func _is_in_view(enemy_pos: Vector2) -> bool:
	var offset = enemy_pos - global_position
	return abs(offset.x) <= VIEW_WIDTH and abs(offset.y) <= VIEW_HEIGHT

# 获取自动瞄准方向（屏幕内最近敌人），无则返回 Vector2.ZERO
func _get_auto_aim_direction() -> Vector2:
	var nearest_enemy = null
	var nearest_distance = INF
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if not _is_in_view(enemy.global_position):
			continue
		var dist = global_position.distance_squared_to(enemy.global_position)
		if dist < nearest_distance:
			nearest_distance = dist
			nearest_enemy = enemy
	
	if nearest_enemy != null:
		return (nearest_enemy.global_position - global_position).normalized()
	
	return Vector2.ZERO

func apply_item_effect(item_type: SupplyData.ItemType) -> String:
	match item_type:
		SupplyData.ItemType.HEAL:
			var heal_amount = MAX_HEALTH * 0.2
			health = minf(health + heal_amount, MAX_HEALTH)
			health_bar.value = health
			return "治疗 +%.0f%% 血量!" % [heal_amount / MAX_HEALTH * 100]
		
		SupplyData.ItemType.SHOTGUN:
			is_shotgun_mode = true
			shotgun_timer = SHOTGUN_DURATION
			return "散弹模式启动! 持续%d秒" % [SHOTGUN_DURATION]
	
	return ""

func _update_shotgun_mode(delta: float):
	if not is_shotgun_mode:
		return
	
	shotgun_timer -= delta
	if shotgun_timer <= 0.0:
		is_shotgun_mode = false
		shotgun_timer = 0.0

func _handle_attack_input():
	if Input.is_key_pressed(KEY_O):
		var cooldown = SHOTGUN_COOLDOWN if is_shotgun_mode else SHOOT_COOLDOWN
		if shoot_cooldown <= 0.0:
			_shoot()
			shoot_cooldown = cooldown
	
	if Input.is_key_pressed(KEY_K):
		if melee_cooldown <= 0.0:
			_melee_attack()
			melee_cooldown = MELEE_COOLDOWN

func _shoot():
	if not bullet_container:
		return
	
	# 子弹朝 facing_dir 方向发射（箭头指向的方向）
	if is_shotgun_mode:
		_fire_shotgun(facing_dir)
	else:
		_fire_normal(facing_dir)

func _fire_normal(direction: Vector2):
	var bullet = BULLET_SCENE.instantiate()
	bullet.position = global_position + direction * 20
	bullet.setup(direction)
	bullet_container.add_child(bullet)

func _fire_shotgun(direction: Vector2):
	var base_angle = direction.angle()
	
	for i in range(SHOTGUN_PELLETS):
		var spread_deg = randf_range(-SHOTGUN_SPREAD, SHOTGUN_SPREAD)
		var spread_rad = deg_to_rad(spread_deg)
		var pellet_dir = Vector2.from_angle(base_angle + spread_rad)
		
		var pellet = SHOTGUN_BULLET_SCENE.instantiate()
		pellet.position = global_position + pellet_dir * 20
		pellet.setup(pellet_dir)
		bullet_container.add_child(pellet)

func _melee_attack():
	if not melee_attack:
		melee_attack = MELEE_SCENE.instantiate()
		get_parent().add_child(melee_attack)
	
	melee_attack.global_position = global_position
	melee_attack.visible = true
	
	await get_tree().create_timer(0.02).timeout
	_check_melee_hits()
	
	await get_tree().create_timer(0.15).timeout
	melee_attack.visible = false

func _check_melee_hits():
	if not melee_attack:
		return
	
	var enemies = melee_attack.get_overlapping_bodies()
	for enemy in enemies:
		if enemy is Enemy and _is_in_view(enemy.global_position):
			enemy.take_damage(40)

func set_bullet_container(container: Node2D) -> void:
	bullet_container = container

func take_damage(dmg: float) -> void:
	health -= dmg
	health_bar.value = health
	print("玩家受伤! 剩余血量: ", health)
	if health <= 0:
		_die()

func get_buff_status() -> String:
	if is_shotgun_mode:
		var remaining = ceil(shotgun_timer)
		return "散弹模式 [%d秒]" % remaining
	return ""

func get_health_ratio() -> float:
	return health / MAX_HEALTH

func _die() -> void:
	print("玩家死亡!")
	player_died.emit()
