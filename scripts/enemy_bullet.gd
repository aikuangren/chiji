extends Area2D

class_name EnemyBullet

const SPEED = 400.0
const DAMAGE = 15
const LIFETIME = 4.0  # 敌人子弹存活更久

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.0

func _ready():
	# 设置碰撞层和掩码
	collision_layer = 32   # 敌人子弹层 (layer 6)
	collision_mask = 1     # 只与玩家层碰撞 (layer 1)
	
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
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
		queue_free()
