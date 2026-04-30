class_name CardBack
extends PanelContainer

## 卡牌背面显示组件 - 趣味解析

@onready var word_label: Label = $MarginContainer/VBox/WordLabel
@onready var chinese_label: Label = $MarginContainer/VBox/ChineseLabel
@onready var fun_fact_label: RichTextLabel = $MarginContainer/VBox/FunFactLabel

var card_data: CardData = null

## 设置卡牌数据并更新显示
func set_card(data: CardData) -> void:
    card_data = data
    
    word_label.text = data.word
    chinese_label.text = data.chinese_meaning
    fun_fact_label.text = "[center]" + data.fun_fact + "[/center]"

## 获取卡牌数据
func get_card_data() -> CardData:
    return card_data
