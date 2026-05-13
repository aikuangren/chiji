extends Area2D

class_name Bullet

const SPEED = 600.0
const DAMAGE = 20
const LIFETIME = 3.0
const MAX_DISTANCE = 350.0

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
		_spawn_hit_effect(body)
		hit_enemy.emit(body)
		queue_free()

func _spawn_hit_effect(enemy: Enemy):
	var particle_scene = preload("res://scenes/particle_effect.tscn")
	var particle = particle_scene.instantiate()
	get_parent().add_child(particle)
	particle.emit(global_position, Color(1.0, 0.9, 0.3), 0)
