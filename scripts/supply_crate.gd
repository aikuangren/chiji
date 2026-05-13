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
	# 隐藏旧视觉节点，改用 _draw 统一绘制
	$Body.visible = false
	$Glow.visible = false
	$Icon.visible = false
	
	var collision = $CollisionShape2D
	if collision.shape:
		collision.shape.size = config["size"]
	
	queue_redraw()

func _draw():
	var size = config["size"]
	var glow_color = config["glow_color"]
	var body_color = config["color"]
	var s = size * 0.5
	
	# 绘制发光层（稍大一圈）
	var glow_rect = Rect2(-s.x - 4, -s.y - 4, size.x + 8, size.y + 8)
	draw_rect(glow_rect, glow_color)
	
	# 绘制主体方块
	var body_rect = Rect2(-s.x, -s.y, size.x, size.y)
	draw_rect(body_rect, body_color)
	
	# 根据道具类型绘制图标
	match item_type:
		SupplyData.ItemType.HEAL:
			_draw_heal_icon()
		SupplyData.ItemType.SHOTGUN:
			_draw_shotgun_icon()

# 绘制治疗十字（红色十字 + 白色方块背景）
func _draw_heal_icon():
	var cross_color = Color(0.9, 0.15, 0.15, 1.0)
	var s = config["size"].x * 0.5  # 半径（取宽度的一半）
	
	# 垂直条（粗十字）
	var v_bar = Rect2(-s * 0.2, -s * 0.7, s * 0.4, s * 1.4)
	draw_rect(v_bar, cross_color)
	# 水平条（粗十字）
	var h_bar = Rect2(-s * 0.7, -s * 0.2, s * 1.4, s * 0.4)
	draw_rect(h_bar, cross_color)

# 绘制散弹图标 - 品字形三角符号
func _draw_shotgun_icon():
	var tri_color = Color(0.9, 0.95, 1.0, 1.0)
	var s = config["size"].x * 0.5
	
	# 三个品字形排列的小方块（上1下2）
	var dot_size = s * 0.3
	var gap = s * 0.35
	
	# 上方
	var top = Rect2(-dot_size/2, -gap - dot_size/2, dot_size, dot_size)
	draw_rect(top, tri_color)
	# 左下方
	var left = Rect2(-gap - dot_size/2, gap - dot_size/2, dot_size, dot_size)
	draw_rect(left, tri_color)
	# 右下方
	var right = Rect2(gap - dot_size/2, gap - dot_size/2, dot_size, dot_size)
	draw_rect(right, tri_color)

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
