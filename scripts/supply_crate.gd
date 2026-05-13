extends StaticBody2D

@export var item_type: SupplyData.ItemType = SupplyData.ItemType.HEAL

var config: Dictionary
var base_y: float
var float_offset: float = 0.0
var _collected: bool = false

func _ready():
	config = SupplyData.get_config(item_type)
	
	_apply_appearance()
	
	base_y = position.y
	float_offset = randf() * TAU
	
	$FloatTimer.timeout.connect(_on_float_timer)
	$PickupArea.body_entered.connect(_on_pickup_area_entered)

func _apply_appearance():
	var body = $Body
	var glow = $Glow
	
	body.color = config["color"]
	glow.color = config["glow_color"]
	
	var size = config["size"]
	body.size = size
	glow.size = size + Vector2(8, 8)
	
	var collision = $CollisionShape2D
	if collision.shape:
		collision.shape.size = size
	
	# 隐藏旧图标，改用自定义绘制
	$Icon.visible = false
	queue_redraw()

func _draw():
	# 根据道具类型绘制图标
	match item_type:
		SupplyData.ItemType.HEAL:
			_draw_heal_icon()
		SupplyData.ItemType.SHOTGUN:
			_draw_shotgun_icon()

# 绘制治疗十字
func _draw_heal_icon():
	var color = Color(0.8, 1.0, 0.8, 1.0)
	var s = config["size"].x * 0.5  # 半径
	
	# 垂直条
	var v_bar = Rect2(-s * 0.2, -s * 0.9, s * 0.4, s * 1.8)
	draw_rect(v_bar, color)
	# 水平条
	var h_bar = Rect2(-s * 0.9, -s * 0.2, s * 1.8, s * 0.4)
	draw_rect(h_bar, color)

# 绘制散弹图标 - 三个小圆点扇形
func _draw_shotgun_icon():
	var color = Color(0.6, 0.85, 1.0, 1.0)
	var s = config["size"].x * 0.5  # 半径
	
	# 三个圆点：中心、左上、右上（扇形排列）
	var dot_radius = s * 0.25
	var offset = s * 0.55
	
	# 中心圆点
	draw_circle(Vector2(0, 0), dot_radius, color)
	# 左上
	draw_circle(Vector2(-offset, -offset * 0.6), dot_radius * 0.8, color)
	# 右上
	draw_circle(Vector2(offset, -offset * 0.6), dot_radius * 0.8, color)
	
	# 三条短辐射线（从中心向外）
	var line_len = s * 0.35
	var line_width = 1.5
	var angles = [0.0, -0.6, 0.6]  # 弧度偏移
	for a in angles:
		var dir = Vector2(sin(a), -cos(a))  # 向上扇形
		var start = dir * (dot_radius + 1)
		var end = dir * (dot_radius + 1 + line_len)
		draw_line(start, end, color, line_width)

func _process(delta):
	var float_amplitude = 3.0
	var float_speed = 2.0
	position.y = base_y + sin(float_offset + Time.get_ticks_msec() / 1000.0 * float_speed) * float_amplitude

func _on_float_timer():
	var tween = create_tween()
	tween.tween_property($Glow, "color:a", 0.3, 0.5)
	tween.tween_property($Glow, "color:a", 0.5, 0.5)

func _on_pickup_area_entered(body: Node2D):
	if _collected:
		return
	
	if body is Player:
		_collected = true
		var effect_text = _apply_effect(body)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): queue_free())
		
		if effect_text != "":
			var game = get_tree().get_first_node_in_group("game")
			if game and game.has_method("show_hint"):
				game.show_hint(effect_text)

func _apply_effect(player: Player) -> String:
	return player.apply_item_effect(item_type)
