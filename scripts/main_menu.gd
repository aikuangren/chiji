extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var character_button: Button = $CenterContainer/VBoxContainer/CharacterButton
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel

func _ready():
	start_button.pressed.connect(_on_start)
	character_button.pressed.connect(_on_character)

func _on_start():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_character():
	# 占位，后续实现角色选择
	pass
