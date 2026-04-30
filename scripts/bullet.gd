extends Area2D

class_name Bullet

const SPEED = 600.0
const DAMAGE = 20
const LIFETIME = 3.0  # 3秒后自动消失

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0

signal hit_enemy(enemy: Enemy)

func _ready():
	# 设置碰撞层和掩码
	collision_layer = 16  # 子弹层 (layer 5)
	collision_mask = 8    # 只与敌人层碰撞 (layer 4)
	
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float):
	# 移动子弹
	position += velocity * delta
	
	# 生命周期计时
	lifetime += delta
	if lifetime >= LIFETIME:
		queue_free()

func setup(dir: Vector2) -> void:
	# 设置子弹方向
	velocity = dir.normalized() * SPEED
	# 让子弹朝运动方向旋转
	rotation = dir.angle()

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(DAMAGE)
		hit_enemy.emit(body)
		queue_free()
