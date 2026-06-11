extends CanvasLayer

const PORTRAIT = preload("res://assets/ui/sci_fi/portrait.png")
const WEAPON_PRIMARY = preload("res://assets/ui/sci_fi/weapon_primary.png")
const WEAPON_SECONDARY = preload("res://assets/ui/sci_fi/weapon_secondary.png")
const WEAPON_HEAVY = preload("res://assets/ui/sci_fi/weapon_heavy.png")
const SKILL_BLADES = preload("res://assets/ui/sci_fi/skill_blades.png")
const SKILL_SHIELD = preload("res://assets/ui/sci_fi/skill_shield.png")
const SKILL_BLAST = preload("res://assets/ui/sci_fi/skill_blast.png")
const SKILL_GRENADE = preload("res://assets/ui/sci_fi/skill_grenade.png")
const SKILL_BLADES_CIRCLE = preload("res://assets/ui/sci_fi/skill_blades_circle.png")
const SKILL_SHIELD_CIRCLE = preload("res://assets/ui/sci_fi/skill_shield_circle.png")
const SKILL_BLAST_CIRCLE = preload("res://assets/ui/sci_fi/skill_blast_circle.png")
const SKILL_GRENADE_CIRCLE = preload("res://assets/ui/sci_fi/skill_grenade_circle.png")
const SKILL_KNIFE_CIRCLE = preload("res://assets/ui/sci_fi/skill_knife_circle.png")
const AMMO_BULLETS = preload("res://assets/ui/sci_fi/ammo_bullets.png")
const SCI_FI_FRAME = preload("res://scripts/sci_fi_frame.gd")

const PANEL_BG = Color(0.035, 0.075, 0.045, 0.82)
const PANEL_BG_DARK = Color(0.02, 0.03, 0.025, 0.86)
const ACCENT = Color(0.38, 1.0, 0.26, 0.92)
const ACCENT_DIM = Color(0.2, 0.55, 0.16, 0.8)
const RED = Color(1.0, 0.22, 0.2, 1.0)
const BLUE = Color(0.25, 0.82, 1.0, 1.0)
const YELLOW = Color(1.0, 0.85, 0.25, 1.0)

var _health_fill: ColorRect
var _health_value: Label
var _level_badge: Label
var _ammo_value: Label
var _health_fill_width: float = 124.0

func _ready() -> void:
	_build_static_hud()
	_style_existing_nodes()
	set_process(true)

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var health = clampf(player.health, 0.0, Player.MAX_HEALTH)
	_health_fill.size.x = _health_fill_width * (health / Player.MAX_HEALTH)
	_health_value.text = "%d/%d" % [roundi(health), Player.MAX_HEALTH]
	
	var level_text = _get_label_text("LevelLabel")
	if level_text != "":
		_level_badge.text = level_text.replace("-", " ")
	
	if player.is_shotgun_mode:
		_ammo_value.text = "5 / 30"
	else:
		_ammo_value.text = "30 / 150"

func _build_static_hud() -> void:
	_build_player_panel()
	_build_mission_panel()
	_build_top_buttons()
	_build_minimap_frame()
	_build_objective_frame()
	_build_weapon_panel()
	_build_skill_cluster()
	_build_guide_panel()

func _style_existing_nodes() -> void:
	var level_label := get_node_or_null("LevelLabel") as Label
	if level_label:
		level_label.position = Vector2(546, 16)
		level_label.size = Vector2(188, 38)
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		level_label.add_theme_font_size_override("font_size", 26)
		level_label.add_theme_color_override("font_color", Color.WHITE)
		level_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		level_label.add_theme_constant_override("outline_size", 3)
		level_label.z_index = 40
	
	var exit_button := get_node_or_null("ExitButton") as Button
	if exit_button:
		exit_button.position = Vector2(864, 24)
		exit_button.size = Vector2(52, 48)
		exit_button.text = "暂停"
		exit_button.add_theme_stylebox_override("normal", _button_style(PANEL_BG_DARK, ACCENT_DIM))
		exit_button.add_theme_stylebox_override("hover", _button_style(Color(0.08, 0.18, 0.07, 0.95), ACCENT))
		exit_button.add_theme_color_override("font_color", Color.WHITE)
		exit_button.add_theme_font_size_override("font_size", 14)
		exit_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		exit_button.z_index = 42
	
	var hint_label := get_node_or_null("HintLabel") as Label
	if hint_label:
		hint_label.position = Vector2(470, 542)
		hint_label.size = Vector2(340, 30)
		hint_label.text = ""
		hint_label.visible = false
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint_label.add_theme_stylebox_override("normal", _button_style(Color(0.02, 0.055, 0.03, 0.84), ACCENT_DIM))
		hint_label.add_theme_font_size_override("font_size", 15)
		hint_label.add_theme_color_override("font_color", Color(0.88, 1.0, 0.82, 0.95))
		hint_label.z_index = 43
	
	var buff_label := get_node_or_null("BuffLabel") as Label
	if buff_label:
		buff_label.position = Vector2(915, 396)
		buff_label.size = Vector2(320, 28)
		buff_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		buff_label.add_theme_font_size_override("font_size", 15)
		buff_label.add_theme_color_override("font_color", BLUE)
		buff_label.z_index = 43
	
	var minimap_container := get_node_or_null("MinimapContainer") as Control
	if minimap_container:
		minimap_container.position = Vector2(1066, 42)
		minimap_container.size = Vector2(180, 180)
		minimap_container.z_index = 43
	
	var enemy_panel := get_node_or_null("EnemyCountPanel") as Control
	if enemy_panel:
		enemy_panel.position = Vector2(1052, 238)
		enemy_panel.size = Vector2(210, 66)
		enemy_panel.z_index = 43
	
	var shooter_label := get_node_or_null("EnemyCountPanel/VBoxContainer/ShooterLabel") as Label
	if shooter_label:
		shooter_label.add_theme_font_size_override("font_size", 17)
		shooter_label.add_theme_color_override("font_color", RED)
	var melee_label := get_node_or_null("EnemyCountPanel/VBoxContainer/MeleeLabel") as Label
	if melee_label:
		melee_label.add_theme_font_size_override("font_size", 17)
		melee_label.add_theme_color_override("font_color", YELLOW)

func _build_player_panel() -> void:
	var panel := _panel("PlayerStatusPanel", Vector2(14, 16), Vector2(360, 116))
	
	var portrait_frame := _panel("PortraitFrame", Vector2(14, 14), Vector2(78, 78))
	portrait_frame.z_index = 1
	panel.add_child(portrait_frame)
	var portrait := _texture_rect("Portrait", PORTRAIT, Vector2(18, 18), Vector2(70, 70))
	portrait.z_index = 2
	panel.add_child(portrait)
	
	var name_label := _label("战士-07", Vector2(108, 15), Vector2(126, 28), 23, Color.WHITE)
	panel.add_child(name_label)
	
	_level_badge = _label("Lv.12", Vector2(286, 19), Vector2(58, 22), 17, YELLOW)
	_level_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(_level_badge)
	
	var health_track := _value_bar(Vector2(134, 51), Vector2(_health_fill_width, 9), RED)
	_health_fill = health_track.get_node("Fill") as ColorRect
	_health_value = _label("100/100", Vector2(268, 41), Vector2(78, 25), 15, Color.WHITE)
	_health_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(_status_icon("+", Vector2(106, 38), RED))
	panel.add_child(health_track)
	panel.add_child(_health_value)
	
	var armor_track := _value_bar(Vector2(134, 75), Vector2(_health_fill_width, 9), BLUE)
	panel.add_child(_status_icon("◇", Vector2(106, 62), BLUE))
	panel.add_child(armor_track)
	var armor_text := _label("600/600", Vector2(268, 65), Vector2(78, 25), 15, Color.WHITE)
	armor_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(armor_text)
	
	var energy_track := _value_bar(Vector2(134, 99), Vector2(_health_fill_width, 9), YELLOW)
	panel.add_child(_status_icon("⚡", Vector2(105, 86), YELLOW))
	panel.add_child(energy_track)
	var energy_text := _label("120/120", Vector2(268, 89), Vector2(78, 25), 15, Color.WHITE)
	energy_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(energy_text)
	add_child(panel)

func _build_mission_panel() -> void:
	var panel := _panel("MissionPanel", Vector2(490, 12), Vector2(300, 70))
	panel.add_child(_label("消灭所有敌人，收集目标点", Vector2(35, 42), Vector2(230, 20), 15, Color(0.9, 1.0, 0.82, 0.92)))
	panel.add_child(_thin_line(Vector2(104, 63), Vector2(94, 2), ACCENT))
	add_child(panel)

func _build_top_buttons() -> void:
	var labels := ["设置", "声音", "背包"]
	for i in labels.size():
		var btn := Button.new()
		btn.name = "TopButton%d" % i
		btn.position = Vector2(922 + i * 58, 24)
		btn.size = Vector2(52, 48)
		btn.text = labels[i]
		btn.add_theme_stylebox_override("normal", _button_style(PANEL_BG_DARK, ACCENT_DIM))
		btn.add_theme_stylebox_override("hover", _button_style(Color(0.08, 0.18, 0.07, 0.95), ACCENT))
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 14)
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.z_index = 42
		add_child(btn)

func _build_minimap_frame() -> void:
	var frame := _panel("MinimapFrame", Vector2(1048, 24), Vector2(220, 216))
	frame.z_index = 35
	add_child(frame)

func _build_objective_frame() -> void:
	var panel := _panel("ObjectiveFrame", Vector2(1040, 238), Vector2(228, 78))
	panel.z_index = 35
	add_child(panel)

func _build_weapon_panel() -> void:
	var panel := _panel("WeaponPanel", Vector2(472, 548), Vector2(336, 68))
	panel.add_child(_label("1", Vector2(14, 12), Vector2(22, 24), 17, Color.WHITE))
	panel.add_child(_label("主武器", Vector2(50, 15), Vector2(72, 22), 16, Color.WHITE))
	var weapon := _texture_rect("PrimaryWeapon", WEAPON_PRIMARY, Vector2(126, 16), Vector2(92, 32))
	panel.add_child(weapon)
	_ammo_value = _label("30 / 150", Vector2(222, 21), Vector2(96, 30), 25, Color.WHITE)
	_ammo_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	panel.add_child(_ammo_value)
	add_child(panel)
	
	var slots := _panel("WeaponSlots", Vector2(472, 620), Vector2(336, 46))
	slots.add_child(_slot("1", WEAPON_PRIMARY, Vector2(8, 6), Vector2(104, 34), true))
	slots.add_child(_slot("2", WEAPON_SECONDARY, Vector2(116, 6), Vector2(104, 34), false))
	slots.add_child(_slot("3", WEAPON_HEAVY, Vector2(224, 6), Vector2(104, 34), false))
	add_child(slots)

func _build_skill_cluster() -> void:
	_add_skill("SkillQ", SKILL_BLADES_CIRCLE, "Q", "5.2s", Vector2(950, 446), 64)
	_add_skill("SkillE", SKILL_SHIELD_CIRCLE, "E", "7.1s", Vector2(1058, 446), 64)
	_add_skill("SkillR", SKILL_BLAST_CIRCLE, "R", "12.3s", Vector2(1166, 446), 64)
	_add_skill("Grenade", SKILL_GRENADE_CIRCLE, "", "手雷", Vector2(930, 582), 70)
	_add_skill("Fire", SKILL_BLADES_CIRCLE, "J", "射击", Vector2(1048, 560), 88)
	_add_skill("Reload", SKILL_KNIFE_CIRCLE, "R", "换弹", Vector2(1174, 582), 70)

func _build_guide_panel() -> void:
	var panel := _panel("GuidePanel", Vector2(22, 500), Vector2(170, 192))
	panel.add_child(_label("操作指南", Vector2(24, 16), Vector2(122, 24), 17, ACCENT))
	panel.add_child(_key_grid(Vector2(34, 50)))
	panel.add_child(_label("移动", Vector2(108, 72), Vector2(50, 22), 15, Color.WHITE))
	panel.add_child(_key("O", Vector2(58, 118)))
	panel.add_child(_label("射击", Vector2(104, 116), Vector2(54, 22), 15, Color.WHITE))
	panel.add_child(_key("K", Vector2(58, 156)))
	panel.add_child(_label("技能", Vector2(104, 154), Vector2(54, 22), 15, Color.WHITE))
	add_child(panel)

func _add_skill(node_name: String, texture: Texture2D, key: String, caption: String, pos: Vector2, diameter: float) -> void:
	var holder := Control.new()
	holder.name = node_name
	holder.position = pos
	holder.size = Vector2(diameter, diameter + 24)
	holder.z_index = 44
	
	var ring := Panel.new()
	ring.position = Vector2.ZERO
	ring.size = Vector2(diameter, diameter)
	ring.add_theme_stylebox_override("panel", _round_style(Color(0.025, 0.055, 0.032, 0.88), ACCENT_DIM, roundi(diameter / 2.0)))
	holder.add_child(ring)
	
	var icon_margin := maxf(5.0, diameter * 0.1)
	var icon := _texture_rect("Icon", texture, Vector2(icon_margin, icon_margin), Vector2(diameter - icon_margin * 2, diameter - icon_margin * 2))
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	holder.add_child(icon)
	
	if key != "":
		var key_label := _label(key, Vector2(diameter - 18, -2), Vector2(22, 22), 16, Color.WHITE)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		key_label.add_theme_stylebox_override("normal", _button_style(Color(0.03, 0.03, 0.025, 0.95), Color(0.75, 0.95, 0.62, 0.7)))
		holder.add_child(key_label)
	
	var text := _label(caption, Vector2(-10, diameter + 2), Vector2(diameter + 20, 20), 14, Color.WHITE)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	holder.add_child(text)
	add_child(holder)

func _slot(number: String, texture: Texture2D, pos: Vector2, size_value: Vector2, active: bool) -> Control:
	var holder := Control.new()
	holder.position = pos
	holder.size = size_value
	var style_color := ACCENT if active else Color(0.25, 0.35, 0.18, 0.75)
	var bg := Panel.new()
	bg.size = size_value
	bg.add_theme_stylebox_override("panel", _button_style(Color(0.04, 0.075, 0.035, 0.82), style_color))
	holder.add_child(bg)
	var index := _label(number, Vector2(4, 2), Vector2(17, 18), 13, Color.WHITE)
	index.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	index.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	holder.add_child(index)
	holder.add_child(_texture_rect("Weapon", texture, Vector2(26, 5), size_value - Vector2(34, 9)))
	return holder

func _key_grid(pos: Vector2) -> Control:
	var holder := Control.new()
	holder.position = pos
	holder.size = Vector2(74, 58)
	holder.add_child(_key("W", Vector2(27, 0)))
	holder.add_child(_key("A", Vector2(0, 27)))
	holder.add_child(_key("S", Vector2(27, 27)))
	holder.add_child(_key("D", Vector2(54, 27)))
	return holder

func _key(text: String, pos: Vector2) -> Label:
	var label := _label(text, pos, Vector2(24, 24), 15, Color.WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_stylebox_override("normal", _button_style(Color(0.05, 0.09, 0.045, 0.9), ACCENT))
	return label

func _panel(node_name: String, pos: Vector2, size_value: Vector2) -> Control:
	var panel = SCI_FI_FRAME.new()
	panel.name = node_name
	panel.position = pos
	panel.size = size_value
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 34
	return panel

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	style.border_color = ACCENT_DIM
	style.set_border_width_all(2)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.shadow_color = Color(0, 0.8, 0.16, 0.18)
	style.shadow_size = 8
	return style

func _button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	return style

func _round_style(bg: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := _button_style(bg, border)
	style.set_corner_radius_all(radius)
	style.set_border_width_all(3)
	return style

func _value_bar(pos: Vector2, size_value: Vector2, fill_color: Color) -> Control:
	var holder := Control.new()
	holder.position = pos
	holder.size = size_value
	
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.size = size_value
	bg.color = Color(0.01, 0.02, 0.012, 0.92)
	holder.add_child(bg)
	
	var fill := ColorRect.new()
	fill.name = "Fill"
	fill.position = Vector2.ZERO
	fill.size = size_value
	fill.color = fill_color
	holder.add_child(fill)
	
	var shine := ColorRect.new()
	shine.name = "Shine"
	shine.position = Vector2(0, 0)
	shine.size = Vector2(size_value.x, 2)
	shine.color = Color(1, 1, 1, 0.18)
	holder.add_child(shine)
	return holder

func _texture_rect(node_name: String, texture: Texture2D, pos: Vector2, size_value: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.name = node_name
	rect.texture = texture
	rect.position = pos
	rect.size = size_value
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _label(text: String, pos: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.65))
	label.add_theme_constant_override("outline_size", 1)
	return label

func _status_icon(text: String, pos: Vector2, color: Color) -> Label:
	var icon := _label(text, pos, Vector2(22, 24), 22, color)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return icon

func _thin_line(pos: Vector2, size_value: Vector2, color: Color) -> ColorRect:
	var line := ColorRect.new()
	line.position = pos
	line.size = size_value
	line.color = color
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line

func _add_corner_lines(panel: Control, size_value: Vector2) -> void:
	var lines := [
		[Vector2(4, 4), Vector2(28, 2)], [Vector2(4, 4), Vector2(2, 28)],
		[Vector2(size_value.x - 32, 4), Vector2(28, 2)], [Vector2(size_value.x - 6, 4), Vector2(2, 28)],
		[Vector2(4, size_value.y - 6), Vector2(28, 2)], [Vector2(4, size_value.y - 32), Vector2(2, 28)],
		[Vector2(size_value.x - 32, size_value.y - 6), Vector2(28, 2)], [Vector2(size_value.x - 6, size_value.y - 32), Vector2(2, 28)]
	]
	for line_data in lines:
		panel.add_child(_thin_line(line_data[0], line_data[1], ACCENT))

func _get_label_text(path: String) -> String:
	var label := get_node_or_null(path) as Label
	if label == null:
		return ""
	return label.text
