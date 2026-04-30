class_name CardData
extends Resource

## 卡牌稀有度等级
enum Rarity {
    COMMON = 1,      # 普通 - 白色
    UNCOMMON = 2,    # 稀有 - 绿色
    RARE = 3,        # 罕见 - 蓝色
    EPIC = 4,        # 史诗 - 紫色
    LEGENDARY = 5,   # 传说 - 橙色
    MYTHIC = 6,      # 神话 - 红色
    SECRET = 7       # 隐藏 - 彩虹
}

@export var id: int = 0
@export var word: String = ""
@export var chinese_meaning: String = ""
@export var fun_fact: String = ""
@export var example_sentence: String = ""
@export var pronunciation: String = ""
@export var rarity: Rarity = Rarity.COMMON
@export var image_path: String = ""

## 稀有度颜色
static func get_rarity_color(rarity: Rarity) -> Color:
    match rarity:
        Rarity.COMMON:    return Color("#A0A0A0")  # 灰色
        Rarity.UNCOMMON:  return Color("#22C55E")  # 绿色
        Rarity.RARE:      return Color("#3B82F6")  # 蓝色
        Rarity.EPIC:      return Color("#A855F7")  # 紫色
        Rarity.LEGENDARY: return Color("#F97316")  # 橙色
        Rarity.MYTHIC:    return Color("#EF4444")  # 红色
        Rarity.SECRET:    return Color("#FF00FF")  # 彩虹色
    return Color.WHITE

## 稀有度名称
static func get_rarity_name(rarity: Rarity) -> String:
    match rarity:
        Rarity.COMMON:    return "普通"
        Rarity.UNCOMMON:  return "稀有"
        Rarity.RARE:      return "罕见"
        Rarity.EPIC:      return "史诗"
        Rarity.LEGENDARY: return "传说"
        Rarity.MYTHIC:    return "神话"
        Rarity.SECRET:    return "隐藏"
    return "未知"
