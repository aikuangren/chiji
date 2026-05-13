extends Area2D

class_name EnemyBullet

const SPEED = 400.0
const DAMAGE = 15
const LIFETIME = 4.0
const MAX_DISTANCE = 350.0

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0
var origin_pos: Vector2

func _ready():
	collision_layer = 32
	collision_mask = 1
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
	# 红色发光子弹 — 核心暗红 + 发光边框
	draw_circle(Vector2.ZERO, 4.0, Color(0.9, 0.15, 0.15, 1.0))
	# 发光边框
	draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.2, 0.2, 0.25))
	draw_circle(Vector2.ZERO, 8.0, Color(1.0, 0.1, 0.1, 0.08))
	# 尾部微弱拖尾（沿飞行方向）
	var dir = velocity.normalized()
	var tail = dir * -10.0
	draw_circle(tail, 2.5, Color(0.8, 0.1, 0.1, 0.2))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
		queue_free()
