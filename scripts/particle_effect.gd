extends Node2D

# 死亡粒子特效 - 简单的小方块飞散效果
const PARTICLE_COUNT = 8
const PARTICLE_SPEED = 120.0
const PARTICLE_LIFETIME = 0.5

var _particles: Array = []
var _timer: float = 0.0

func emit(pos: Vector2, color: Color):
	global_position = pos
	
	for i in range(PARTICLE_COUNT):
		var rect = ColorRect.new()
		rect.size = Vector2(4, 4)
		rect.color = color
		var angle = randf() * TAU
		var speed = randf_range(PARTICLE_SPEED * 0.5, PARTICLE_SPEED)
		rect.set_meta("vel", Vector2(cos(angle), sin(angle)) * speed)
		rect.set_meta("lifetime", PARTICLE_LIFETIME)
		rect.set_meta("age", 0.0)
		add_child(rect)
		_particles.append(rect)
	
	_timer = PARTICLE_LIFETIME

func _process(delta: float):
	if _particles.is_empty():
		return
	
	_timer -= delta
	
	for p in _particles:
		if not is_instance_valid(p):
			continue
		var age: float = p.get_meta("age") + delta
		p.set_meta("age", age)
		var vel: Vector2 = p.get_meta("vel")
		p.position += vel * delta
		var ratio = age / PARTICLE_LIFETIME
		p.modulate.a = 1.0 - ratio
		p.scale = Vector2(1, 1) * (1.0 - ratio * 0.5)
	
	if _timer <= 0.0:
		for p in _particles:
			if is_instance_valid(p):
				p.queue_free()
		_particles.clear()
		queue_free()
