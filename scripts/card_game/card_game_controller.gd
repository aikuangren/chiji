class_name CardGameController
extends Node2D

## 卡牌游戏核心控制器 - 管理抽卡、卡牌展示和翻转

# 卡牌间距
const CARD_SPACING: float = 170.0
const CARD_START_X: float = -340.0  # 5张卡牌的起始X位置

# 卡牌节点引用
var card_slots: Array[CardSlot] = []

# 卡包系统
var card_pack: CardPack

# 统计
var total_packs_opened: int = 0

# 卡牌预制体引用
var card_front_scene: PackedScene
var card_back_scene: PackedScene

# 当前展开的卡牌
var revealed_card_index: int = -1

signal all_cards_revealed

class CardSlot:
    ## 卡牌槽位 - 管理单张卡牌的显示和翻转状态
    
    var card_node: Node2D
    var front_instance: CardFront
    var back_instance: CardBack
    var card_data: CardData
    var is_flipped: bool = false
    var is_spawned: bool = false
    
    func _init(parent: Node2D, front_scene: PackedScene, back_scene: PackedScene):
        # 创建卡牌容器
        card_node = Node2D.new()
        card_node.visible = false
        parent.add_child(card_node)
        
        # 实例化正面和背面
        front_instance = front_scene.instantiate()
        back_instance = back_scene.instantiate()
        
        # 初始显示背面（等待翻转）
        card_node.add_child(back_instance)
        card_node.add_child(front_instance)
        front_instance.visible = false
        back_instance.visible = true
    
    func set_card(data: CardData, index: int) -> void:
        card_data = data
        front_instance.set_card(data)
        back_instance.set_card(data)
        card_node.position = Vector2(CARD_START_X + index * CARD_SPACING, 0)
        card_node.scale = Vector2(0.8, 0.8)
        is_flipped = false
        is_spawned = true
        card_node.visible = true
    
    func flip_to_front() -> void:
        if is_flipped:
            return
        is_flipped = true
        
        # 3D翻转效果用2D缩放模拟
        var tween: Tween = card_node.create_tween()
        tween.set_parallel(true)
        # 先缩小
        tween.tween_property(card_node, "scale:x", 0.0, 0.15)
        # 切换显示
        tween.tween_callback(func(): 
            back_instance.visible = false
            front_instance.visible = true
        )
        # 再放大
        tween.tween_property(card_node, "scale:x", 0.8, 0.15)
    
    func flip_to_back() -> void:
        if not is_flipped:
            return
        is_flipped = false
        
        var tween: Tween = card_node.create_tween()
        tween.set_parallel(true)
        tween.tween_property(card_node, "scale:x", 0.0, 0.15)
        tween.tween_callback(func(): 
            front_instance.visible = false
            back_instance.visible = true
        )
        tween.tween_property(card_node, "scale:x", 0.8, 0.15)
    
    func hide_card() -> void:
        var tween: Tween = card_node.create_tween()
        tween.set_parallel(true)
        tween.tween_property(card_node, "scale", Vector2(0.6, 0.6), 0.2)
        tween.tween_property(card_node, "modulate:a", 0.0, 0.2)
        tween.tween_callback(func(): 
            card_node.visible = false
            card_node.modulate.a = 1.0
        )
    
    func show_card() -> void:
        card_node.scale = Vector2(0.6, 0.6)
        card_node.modulate.a = 0.0
        card_node.visible = true
        
        var tween: Tween = card_node.create_tween()
        tween.set_parallel(true)
        tween.tween_property(card_node, "scale", Vector2(0.8, 0.8), 0.3)
        tween.tween_property(card_node, "modulate:a", 1.0, 0.3)

func _ready() -> void:
    # 加载卡牌预制体
    card_front_scene = preload("res://scenes/card_game/card_front.tscn")
    card_back_scene = preload("res://scenes/card_game/card_back.tscn")
    
    # 初始化卡包系统
    card_pack = CardPack.new()
    add_child(card_pack)
    
    # 连接抽卡信号
    card_pack.pack_opened.connect(_on_pack_opened)
    
    # 获取UI引用
    var draw_button: Button = $DrawButton
    draw_button.pressed.connect(_on_draw_button_pressed)
    
    # 初始化5个卡牌槽位
    for i in range(5):
        var slot = CardSlot.new(self, card_front_scene, card_back_scene)
        card_slots.append(slot)
    
    # 隐藏所有卡牌
    for slot in card_slots:
        slot.card_node.visible = false

func _on_draw_button_pressed() -> void:
    # 播放抽卡音效的占位位置
    # $AudioStreamPlayer.play()
    
    # 先隐藏之前的卡牌（如果有）
    _hide_all_cards()
    
    # 延迟一点再显示新卡牌
    await get_tree().create_timer(0.3).timeout
    
    # 抽取5张卡
    var drawn_cards: Array[CardData] = card_pack.open_pack()
    total_packs_opened += 1
    _update_stats()
    
    # 设置卡牌数据并显示
    for i in range(drawn_cards.size()):
        card_slots[i].set_card(drawn_cards[i], i)
        card_slots[i].show_card()
        # 每张卡延迟一点出现
        await get_tree().create_timer(0.15).timeout
    
    revealed_card_index = -1

func _on_pack_opened(cards: Array[CardData]) -> void:
    # 抽卡完成后的处理（可用于播放动画、更新统计等）
    print("抽到 %d 张卡牌" % cards.size())

func _hide_all_cards() -> void:
    for slot in card_slots:
        if slot.is_spawned:
            slot.hide_card()

func _update_stats() -> void:
    var stats_label: Label = $StatsLabel
    stats_label.text = "抽卡次数: %d" % total_packs_opened

func _process(_delta: float) -> void:
    # 检测鼠标点击来翻转卡牌
    if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
        _try_flip_card_at_mouse()

func _try_flip_card_at_mouse() -> void:
    var mouse_pos: Vector2 = get_global_mouse_position()
    var card_container: Node2D = $CardContainer
    
    # 转换为相对于卡牌容器的位置
    var local_pos: Vector2 = card_container.to_local(mouse_pos)
    
    # 检查是否点击了某张卡牌
    for i in range(card_slots.size()):
        var slot: CardSlot = card_slots[i]
        if not slot.is_spawned or not slot.card_node.visible:
            continue
        
        var card_pos: Vector2 = slot.card_node.position
        var card_size: Vector2 = Vector2(160, 220) * slot.card_node.scale
        
        # 检查是否在卡牌范围内
        if abs(local_pos.x - card_pos.x) < card_size.x / 2 and abs(local_pos.y - card_pos.y) < card_size.y / 2:
            _flip_card(i)
            break

func _flip_card(index: int) -> void:
    var slot: CardSlot = card_slots[index]
    
    if slot.is_flipped:
        slot.flip_to_back()
    else:
        slot.flip_to_front()
