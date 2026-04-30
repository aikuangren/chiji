extends Area2D

class_name Bullet

const SPEED = 600.0
const DAMAGE = 20
const LIFETIME = 3.0
const MAX_DISTANCE = 350.0  # 最大飞行距离

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0
var origin_pos: Vector2  # 发射时的位置

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

func setup(dir: Vector2) -> void:
	velocity = dir.normalized() * SPEED
	rotation = dir.angle()

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(DAMAGE)
		hit_enemy.emit(body)
		queue_free()
