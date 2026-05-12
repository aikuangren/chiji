extends Node2D

# 粒子特效类型：0=HIT 1=DEATH 2=EXPLOSION

const HIT_COUNT = 6
const HIT_SPEED = 100.0
const HIT_LIFETIME = 0.3
const HIT_SIZE = 4.0

const DEATH_COUNT = 14
const DEATH_SPEED = 140.0
const DEATH_LIFETIME = 0.7
const DEATH_SIZE = 6.0

const EXPLOSION_COUNT = 20
const EXPLOSION_SPEED = 180.0
const EXPLOSION_LIFETIME = 0.8
const EXPLOSION_SIZE = 8.0

var _particles: Array = []
var _timer: float = 0.0
var _ring: ColorRect = null  # 扩散光环

func emit(pos: Vector2, color: Color, effect_type: int = 0):
	global_position = pos
	
	var count: int
	var speed: float
	var lifetime: float
	var size: float
	
	match effect_type:
		0:  # HIT
			count = HIT_COUNT; speed = HIT_SPEED; lifetime = HIT_LIFETIME; size = HIT_SIZE
		1:  # DEATH
			count = DEATH_COUNT; speed = DEATH_SPEED; lifetime = DEATH_LIFETIME; size = DEATH_SIZE
		2:  # EXPLOSION
			count = EXPLOSION_COUNT; speed = EXPLOSION_SPEED; lifetime = EXPLOSION_LIFETIME; size = EXPLOSION_SIZE
	
	for i in range(count):
		var rect = ColorRect.new()
		rect.size = Vector2(size, size)
		rect.color = color
		var angle = randf() * TAU
		var spd = randf_range(speed * 0.4, speed)
		rect.set_meta("vel", Vector2(cos(angle), sin(angle)) * spd)
		rect.set_meta("lifetime", lifetime)
		rect.set_meta("age", 0.0)
		add_child(rect)
		_particles.append(rect)
	
	# 爆炸/死亡特效加一个扩散光环
	if effect_type != 0:
		_ring = ColorRect.new()
		_ring.size = Vector2(4, 4)
		_ring.color = Color(color.r, color.g, color.b, 0.5)
		_ring.position = Vector2(-2, -2)
		add_child(_ring)
	
	_timer = lifetime

func _process(delta: float):
	if _particles.is_empty() and _ring == null:
		return
	
	_timer -= delta
	
	for p in _particles:
		if not is_instance_valid(p):
			continue
		var age: float = p.get_meta("age") + delta
		p.set_meta("age", age)
		var vel: Vector2 = p.get_meta("vel")
		p.position += vel * delta
		var lifetime: float = p.get_meta("lifetime")
		var ratio = age / lifetime
		p.modulate.a = 1.0 - ratio
		p.scale = Vector2(1, 1) * (1.0 - ratio * 0.3)
	
	# 扩散光环
	if _ring != null and is_instance_valid(_ring):
		var progress = 1.0 - maxf(_timer / _timer, 0.0) if _timer > 0 else 1.0
		var ring_size = 2.0 + progress * 30.0
		_ring.size = Vector2(ring_size, ring_size)
		_ring.position = Vector2(-ring_size / 2, -ring_size / 2)
		_ring.modulate.a = 0.5 * (1.0 - progress)
	
	if _timer <= 0.0:
		for p in _particles:
			if is_instance_valid(p):
				p.queue_free()
		if _ring != null and is_instance_valid(_ring):
			_ring.queue_free()
		_particles.clear()
		_ring = null
		queue_free()
