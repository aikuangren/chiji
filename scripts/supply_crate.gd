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
	
	$Icon.text = config["icon"]

func _process(delta):
	var float_amplitude = 3.0
	var float_speed = 2.0
	position.y = base_y + sin(float_offset + Time.get_ticks_msec() / 1000.0 * float_speed) * float_amplitude

func _on_float_timer():
	var tween = create_tween()
	tween.tween_property($Glow, "color:a", 0.3, 0.5)
	tween.tween_property($Glow, "color:a", 0.5, 0.5)

# 玩家碰撞检测 - 自动拾取
func _on_pickup_area_entered(body: Node2D):
	if _collected:
		return
	
	if body is Player:
		_collected = true
		# 应用道具效果
		var effect_text = _apply_effect(body)
		# 播放收集动画
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): queue_free())
		
		# 显示拾取提示（通过game.gd的hint_label）
		if effect_text != "":
			var game = get_tree().get_first_node_in_group("game")
			if game and game.has_method("show_hint"):
				game.show_hint(effect_text)

func _apply_effect(player: Player) -> String:
	return player.apply_item_effect(item_type)
