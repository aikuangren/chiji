extends Area2D

class_name ShotgunBullet

const SPEED = 500.0
const DAMAGE = 12
const LIFETIME = 2.5
const MAX_DISTANCE = 280.0

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0
var origin_pos: Vector2

signal hit_enemy(enemy: Enemy)

func _ready():
	collision_layer = 16
	collision_mask = 8
	body_entered.connect(_on_body_entered)
	origin_pos = global_position

func _physics_process(delta: float):
	if origin_pos.distance_to(global_position) > MAX_DISTANCE:
		queue_free()
		return
	
	position += velocity * delta
	lifetime += delta
	if lifetime >= LIFETIME:
		queue_free()
	queue_redraw()

func setup(dir: Vector2) -> void:
	velocity = dir.normalized() * SPEED
	rotation = dir.angle()

func _draw():
	# 蓝色发光小方块 — 中心亮蓝，外围发光
	# 核心
	draw_circle(Vector2.ZERO, 3.0, Color(0.4, 0.8, 1.0, 1.0))
	# 发光层（半透明扩散）
	draw_circle(Vector2.ZERO, 5.0, Color(0.3, 0.6, 1.0, 0.3))
	draw_circle(Vector2.ZERO, 7.0, Color(0.2, 0.4, 1.0, 0.1))

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(DAMAGE)
		_spawn_hit_effect()
		hit_enemy.emit(body)
		queue_free()

func _spawn_hit_effect():
	var particle_scene = preload("res://scenes/particle_effect.tscn")
	var particle = particle_scene.instantiate()
	get_parent().add_child(particle)
	particle.emit(global_position, Color(0.3, 0.7, 1.0), 0)
