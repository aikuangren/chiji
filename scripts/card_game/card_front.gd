class_name CardFront
extends PanelContainer

## 卡牌正面显示组件

@onready var rarity_badge: Label = $MarginContainer/VBox/RarityBadge
@onready var word_label: Label = $MarginContainer/VBox/WordLabel
@onready var image_placeholder: ColorRect = $MarginContainer/VBox/ImagePlaceholder
@onready var chinese_label: Label = $MarginContainer/VBox/ChineseLabel
@onready var pronunciation_label: Label = $MarginContainer/VBox/PronunciationLabel
@onready var card_background: ColorRect = $CardBackground

var card_data: CardData = null

func _ready() -> void:
    pass

## 设置卡牌数据并更新显示
func set_card(data: CardData) -> void:
    card_data = data
    
    word_label.text = data.word
    chinese_label.text = data.chinese_meaning
    pronunciation_label.text = data.pronunciation
    rarity_badge.text = CardData.get_rarity_name(data.rarity)
    
    # 设置稀有度颜色
    var color: Color = CardData.get_rarity_color(data.rarity)
    rarity_badge.add_theme_color_override("font_color", color)
    
    # 设置卡牌边框颜色
    var style_box: StyleBoxFlat = StyleBoxFlat.new()
    style_box.bg_color = Color(0.95, 0.95, 0.95, 1)
    style_box.border_color = color
    style_box.border_width_left = 3
    style_box.border_width_top = 3
    style_box.border_width_right = 3
    style_box.border_width_bottom = 3
    style_box.corner_radius_top_left = 10
    style_box.corner_radius_top_right = 10
    style_box.corner_radius_bottom_right = 10
    style_box.corner_radius_bottom_left = 10
    add_theme_stylebox_override("panel", style_box)
    
    # 设置图片占位符颜色（基于稀有度）
    image_placeholder.color = color.lightened(0.7)

## 获取卡牌数据
func get_card_data() -> CardData:
    return card_data
