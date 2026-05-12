extends CharacterBody2D

class_name Enemy

signal enemy_killed(enemy_type: int)

enum Type { MELEE, SHOOTER }

const EXPLOSION_DAMAGE = 35.0
const EXPLOSION_RADIUS = 80.0

const SCREEN_VIEW_RANGE = 500.0

const SHOOTER_ATTACK_RANGE = 300.0
const MELEE_ACTIVATE_RANGE = 200.0

var enemy_type: Type
var speed: float = 80.0
var health: float = 50.0
var facing_dir: Vector2 = Vector2.RIGHT

var bullet_scene: PackedScene = preload("res://scenes/enemy_bullet.tscn")
var shoot_cooldown: float = 2.0
var shoot_timer: float = 0.0

var home_position: Vector2
var vision_range: float = 200.0
var chase_speed: float = 120.0
var patrol_speed: float = 60.0
var is_chasing: bool = false
var state: String = "patrol"

var sprite
var hitbox: Area2D
var health_bar: ProgressBar

var is_dead: bool = false

func _ready() -> void:
	add_to_group("enemies")
	sprite = $Sprite
	hitbox = $Hitbox
	health_bar = $HealthBar
	
	var shooter_chance = randf()
	if shooter_chance < 0.3:
		enemy_type = Type.SHOOTER
		speed = 60.0
		sprite.modulate = Color(1.0, 0.15, 0.15)
	else:
		enemy_type = Type.MELEE
		sprite.modulate = Color(0.15, 0.15, 0.15)
		home_position = global_position
		state = "patrol"
	
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	var player = _get_player()
	if player == null:
		velocity = Vector2.ZERO
		if enemy_type == Type.MELEE:
			state = "patrol"
		return
	
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player > SCREEN_VIEW_RANGE:
		velocity = Vector2.ZERO
		return
	
	match enemy_type:
		Type.MELEE:
			_ai_melee(delta, player, dist_to_player)
		Type.SHOOTER:
			_ai_shooter(delta, player, dist_to_player)
	
	move_and_slide()

func _ai_melee(delta: float, player: Node2D, dist_to_player: float) -> void:
	match state:
		"patrol":
			velocity = Vector2.ZERO
			if dist_to_player <= MELEE_ACTIVATE_RANGE:
				state = "chase"
				speed = chase_speed
		
		"chase":
			if dist_to_player <= SCREEN_VIEW_RANGE:
				var dir = (player.global_position - global_position).normalized()
				velocity = dir * chase_speed
				facing_dir = dir
			else:
				state = "patrol"
				velocity = Vector2.ZERO
				speed = patrol_speed

func _ai_shooter(delta: float, player: Node2D, dist_to_player: float) -> void:
	var dir = (player.global_position - global_position).normalized()
	facing_dir = dir
	
	if dist_to_player <= SHOOTER_ATTACK_RANGE:
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:
			shoot_timer = 0.0
			_spawn_bullet()
		velocity = dir * speed * 0.3
	else:
		velocity = Vector2.ZERO
		shoot_timer = 0.0

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		if enemy_type == Type.MELEE:
			_explode()

func _explode() -> void:
	if is_dead:
		return
	is_dead = true
	
	# 爆炸粒子特效
	var particle_scene = preload("res://scenes/particle_effect.tscn")
	var particle = particle_scene.instantiate()
	get_parent().add_child(particle)
	particle.emit(global_position, Color(1.0, 0.5, 0.0))
	
	var player = _get_player()
	if player == null:
		queue_free()
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist <= EXPLOSION_RADIUS:
		player.take_damage(EXPLOSION_DAMAGE)
	
	enemy_killed.emit(enemy_type)
	queue_free()

func _spawn_bullet() -> void:
	var container = get_tree().get_first_node_in_group("Bullets")
	if container == null:
		container = get_parent()
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	var player = _get_player()
	if player != null:
		bullet.setup((player.global_position - global_position).normalized())
	else:
		bullet.setup(facing_dir)
	
	container.add_child(bullet)

func _get_player() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func take_damage(dmg: float) -> void:
	health -= dmg
	if health_bar:
		health_bar.value = health
	
	# 受击反馈：敌人闪白
	var tween = create_tween()
	tween.tween_method(func(v): modulate.a = v, 0.3, 1.0, 0.12)
	
	if health <= 0 and not is_dead:
		is_dead = true
		die()

func die() -> void:
	# 死亡粒子特效
	_spawn_death_particles()
	enemy_killed.emit(enemy_type)
	queue_free()

func _spawn_death_particles():
	var particle_scene = preload("res://scenes/particle_effect.tscn")
	var particle = particle_scene.instantiate()
	get_parent().add_child(particle)
	var color = Color(1.0, 0.15, 0.15) if enemy_type == Type.SHOOTER else Color(0.5, 0.5, 0.5)
	particle.emit(global_position, color)
