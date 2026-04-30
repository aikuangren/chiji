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

func setup(dir: Vector2) -> void:
	velocity = dir.normalized() * SPEED
	rotation = dir.angle()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
		queue_free()
