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

func setup(dir: Vector2) -> void:
	velocity = dir.normalized() * SPEED
	rotation = dir.angle()

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(DAMAGE)
		hit_enemy.emit(body)
		queue_free()
