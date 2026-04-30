class_name CardGameMain
extends Node2D

## 抽卡游戏主入口场景

@onready var back_button: Button = $BackButton
@onready var card_game: CardGameController = $CardGame

func _ready() -> void:
    back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
    # 返回到原来的主场景
    get_tree().change_scene_to_file("res://scenes/main.tscn")
