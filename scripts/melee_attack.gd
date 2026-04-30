extends Area2D

class_name MeleeAttack

const DAMAGE = 40
const DURATION = 0.2  # 近战攻击持续时间

func _ready():
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)

func attack(pos: Vector2) -> void:
	# 设置位置到玩家位置
	global_position = pos
	# 显示并开始计时
	visible = true
	
	# 延迟执行碰撞检测
	await get_tree().create_timer(0.05).timeout
	_check_enemies()
	
	# 持续时间后消失
	await get_tree().create_timer(DURATION).timeout
	queue_free()

func _check_enemies() -> void:
	# 获取范围内的所有敌人
	var enemies = get_overlapping_bodies()
	for enemy in enemies:
		if enemy is Enemy:
			enemy.take_damage(DAMAGE)

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(DAMAGE)
