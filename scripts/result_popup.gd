extends CanvasLayer

class_name ResultPopup

enum Result { VICTORY, DEFEAT }

@onready var panel: ColorRect = $Panel
@onready var title_label: Label = $Panel/CenterContainer/VBoxContainer/TitleLabel
@onready var stats_label: Label = $Panel/CenterContainer/VBoxContainer/StatsLabel
@onready var action_button: Button = $Panel/CenterContainer/VBoxContainer/ActionButton
@onready var close_button: Button = $Panel/CenterContainer/VBoxContainer/CloseButton

var _result_type: Result
var _kills: int = 0
var _time_survived: float = 0.0

func _ready():
	hide()
	panel.modulate.a = 0.0

func show_result(result: Result, kills: int, time_survived: float):
	_result_type = result
	_kills = kills
	_time_survived = time_survived
	
	match result:
		Result.VICTORY:
			title_label.text = "胜利!"
			title_label.modulate = Color(0.2, 0.8, 0.2, 1)
			action_button.text = "下一关卡"
			action_button.pressed.connect(_on_next_level)
			close_button.text = "返回主菜单"
			close_button.pressed.connect(_on_main_menu)
		
		Result.DEFEAT:
			title_label.text = "失败!"
			title_label.modulate = Color(0.9, 0.2, 0.2, 1)
			action_button.text = "重新挑战"
			action_button.pressed.connect(_on_retry)
			close_button.text = "返回主菜单"
			close_button.pressed.connect(_on_main_menu)
	
	var time_str = "%.1f秒" % time_survived
	stats_label.text = "击杀: %d\n存活时间: %s" % [kills, time_str]
	
	show()
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)

func _on_retry():
	get_tree().reload_current_scene()

func _on_next_level():
	get_tree().reload_current_scene()

func _on_main_menu():
	get_tree().change_scene_to_file("res://scenes/card_game/card_game_main.tscn")
