class_name CardPack
extends Node

## 抽卡包系统 - 管理抽卡概率和卡池

signal pack_opened(cards: Array[CardData])

# 各稀有度概率权重 (可调整)
@export var rarity_weights: Dictionary = {
    CardData.Rarity.COMMON: 45,    # 45%
    CardData.Rarity.UNCOMMON: 28,   # 28%
    CardData.Rarity.RARE: 15,       # 15%
    CardData.Rarity.EPIC: 8,        # 8%
    CardData.Rarity.LEGENDARY: 3,   # 3%
    CardData.Rarity.MYTHIC: 1,      # 1%
    CardData.Rarity.SECRET: 0       # 0% - 特殊途径获得
}

# 保底机制
@export var pity_rare_threshold: int = 10       # 每10抽保底Rare
@export var pity_epic_threshold: int = 50       # 每50抽保底Epic
@export var pity_legendary_threshold: int = 100 # 每100抽保底Legendary

var _card_pool: Array[CardData] = []
var _current_pity: int = 0

func _ready() -> void:
    _load_card_pool()

## 加载卡池
func _load_card_pool() -> void:
    # 创建示例卡牌数据
    _create_sample_cards()

## 创建示例卡牌 (后续会从数据文件加载)
func _create_sample_cards() -> void:
    var sample_words: Array[Dictionary] = [
        # Common (Grade 1-2)
        {"word": "apple", "chinese": "苹果", "fun": "苹果的拉丁文名字来自罗马人，他们把苹果叫做'malum maturus'，意思是成熟的果实。", "rarity": CardData.Rarity.COMMON},
        {"word": "book", "chinese": "书", "fun": "世界上最贵的书是一本《达芬奇手稿》，价值高达3080万美元！", "rarity": CardData.Rarity.COMMON},
        {"word": "cat", "chinese": "猫", "fun": "猫会发出超过100种不同的声音，而狗只能发出约10种。", "rarity": CardData.Rarity.COMMON},
        {"word": "dog", "chinese": "狗", "fun": "狗的嗅觉比人类强10000倍！它们能闻到千里之外的味道。", "rarity": CardData.Rarity.COMMON},
        {"word": "egg", "chinese": "鸡蛋", "fun": "鸡蛋的形状其实是椭圆形，这样滚动时会转弯而不是直线滚。", "rarity": CardData.Rarity.COMMON},
        {"word": "fish", "chinese": "鱼", "fun": "鱼睡觉时不会闭上眼睛，因为它们没有眼睑！", "rarity": CardData.Rarity.COMMON},
        {"word": "girl", "chinese": "女孩", "fun": "世界上第一个程序员是一位女性，她叫阿达·洛芙莱斯。", "rarity": CardData.Rarity.COMMON},
        {"word": "hand", "chinese": "手", "fun": "人类的手有27块骨头，占全身骨骼总数的1/4！", "rarity": CardData.Rarity.COMMON},
        
        # Uncommon (Grade 3)
        {"word": "beautiful", "chinese": "美丽的", "fun": "单词 'beautiful' 有9个字母，但世界上最长的单词有189819个字母！", "rarity": CardData.Rarity.UNCOMMON},
        {"word": "children", "chinese": "孩子们", "fun": "'Children' 这个词在古英语中是 'cild' + 'eru'，意思是 '有孩子的人'。", "rarity": CardData.Rarity.UNCOMMON},
        {"word": "different", "chinese": "不同的", "fun": "地球上没有两片完全相同的雪花，也没有两个完全相同的人。", "rarity": CardData.Rarity.UNCOMMON},
        {"word": "environment", "chinese": "环境", "fun": "地球是唯一一个名字不是来自神的星球。", "rarity": CardData.Rarity.UNCOMMON},
        {"word": "favorite", "chinese": "最喜爱的", "fun": "你最喜欢的颜色可能和你的心情有关！蓝色通常让人感到平静。", "rarity": CardData.Rarity.UNCOMMON},
        {"word": "grammar", "chinese": "语法", "fun": "英语是世界上最多国家使用的官方语言，超过50个国家！", "rarity": CardData.Rarity.UNCOMMON},
        
        # Rare (Grade 4)
        {"word": "absolutely", "chinese": "绝对地", "fun": "'Absolutely' 有10个字母，但它的反义词 'not' 只有3个字母。", "rarity": CardData.Rarity.RARE},
        {"word": "brilliant", "chinese": "出色的", "fun": "人的大脑可以在一秒钟内处理1000万千比特的信息！", "rarity": CardData.Rarity.RARE},
        {"word": "celebrate", "chinese": "庆祝", "fun": "世界上最大的派对是巴西里约热内卢的嘉年华，有200万人参加！", "rarity": CardData.Rarity.RARE},
        {"word": "delicious", "chinese": "美味的", "fun": "巧克力对狗是有毒的，但对我们来说是美味的零食！", "rarity": CardData.Rarity.RARE},
        {"word": "excellent", "chinese": "优秀的", "fun": "蜜蜂可以识别人脸，这就是为什么它们总能找到你！", "rarity": CardData.Rarity.RARE},
        
        # Epic (Grade 5-6)
        {"word": "accomplishment", "chinese": "成就", "fun": "第一个完成马拉松的人是希腊士兵费迪皮迪兹，他跑完就累死了！", "rarity": CardData.Rarity.EPIC},
        {"word": "breathtaking", "chinese": "令人惊叹的", "fun": "珠穆朗玛峰每年长高约4毫米，它是世界上最高的山！", "rarity": CardData.Rarity.EPIC},
        {"word": "championship", "chinese": "锦标赛", "fun": "世界杯足球赛每4年举办一次，是世界上观看人数最多的体育赛事！", "rarity": CardData.Rarity.EPIC},
        {"word": "extraordinary", "chinese": "非凡的", "fun": "水獭会手牵手睡觉，这样它们就不会被水流冲散！", "rarity": CardData.Rarity.EPIC},
        
        # Legendary (Grade 7+)
        {"word": "photosynthesis", "chinese": "光合作用", "fun": "植物白天释放氧气，晚上释放二氧化碳。所以清晨的空气最清新！", "rarity": CardData.Rarity.LEGENDARY},
        {"word": "determination", "chinese": "决心", "fun": "爱因斯坦小时候说话很晚，老师认为他智力有问题，但他后来成为了最伟大的科学家！", "rarity": CardData.Rarity.LEGENDARY},
        {"word": "responsibility", "chinese": "责任", "fun": "蜘蛛丝比钢丝还强，一根铅笔粗的蜘蛛丝可以阻止一架波音747！", "rarity": CardData.Rarity.LEGENDARY},
        
        # Mythic (初中核心词汇)
        {"word": "phenomenon", "chinese": "现象", "fun": "彩虹其实不是弯曲的，而是一个完整的圆！我们只能看到一半。", "rarity": CardData.Rarity.MYTHIC},
        {"word": "sophisticated", "chinese": "精密的", "fun": "蜜蜂的翅膀每秒拍动200次，它们可以记住人脸！", "rarity": CardData.Rarity.MYTHIC},
        
        # Secret (特殊卡牌)
        {"word": "serendipity", "chinese": "意外发现美好事物的运气", "fun": "这个单词是18世纪英国作家霍勒斯·瓦尔普创造的，意思是意外发现美好事物的运气。", "rarity": CardData.Rarity.SECRET},
        {"word": "mellifluous", "chinese": "悦耳的", "fun": "这个单词来自拉丁语，意思是像蜂蜜一样甜美的声音。", "rarity": CardData.Rarity.SECRET},
    ]
    
    for i in range(sample_words.size()):
        var data: CardData = CardData.new()
        data.id = i + 1
        data.word = sample_words[i]["word"]
        data.chinese_meaning = sample_words[i]["chinese"]
        data.fun_fact = sample_words[i]["fun"]
        data.rarity = sample_words[i]["rarity"]
        data.example_sentence = "I learned the word '%s' today!" % sample_words[i]["word"]
        data.pronunciation = "/" + sample_words[i]["word"] + "/"
        _card_pool.append(data)

## 根据权重随机选择一个稀有度
func _roll_rarity() -> CardData.Rarity:
    # 检查保底
    _current_pity += 1
    
    var guaranteed_rarity: CardData.Rarity = CardData.Rarity.COMMON
    
    if _current_pity >= pity_legendary_threshold:
        guaranteed_rarity = CardData.Rarity.LEGENDARY
        _current_pity = 0
    elif _current_pity >= pity_epic_threshold:
        guaranteed_rarity = CardData.Rarity.EPIC
    elif _current_pity >= pity_rare_threshold:
        guaranteed_rarity = CardData.Rarity.RARE
    
    # 90%概率使用保底
    if randf() < 0.9 and guaranteed_rarity > CardData.Rarity.COMMON:
        return guaranteed_rarity
    
    # 正常概率抽取
    var total_weight: int = 0
    for rarity in rarity_weights:
        total_weight += rarity_weights[rarity]
    
    var roll: float = randf() * total_weight
    
    for rarity in rarity_weights:
        roll -= rarity_weights[rarity]
        if roll <= 0:
            return rarity as CardData.Rarity
    
    return CardData.Rarity.COMMON

## 从卡池中获取指定稀有度的随机卡牌
func _get_random_card_by_rarity(rarity: CardData.Rarity) -> CardData:
    var eligible_cards: Array[CardData] = []
    
    for card in _card_pool:
        if card.rarity == rarity:
            eligible_cards.append(card)
    
    if eligible_cards.is_empty():
        # 如果没有该稀有度的卡，返回普通卡
        return _card_pool[randi() % _card_pool.size()]
    
    return eligible_cards[randi() % eligible_cards.size()]

## 打开卡包 - 抽取5张卡
func open_pack() -> Array[CardData]:
    var drawn_cards: Array[CardData] = []
    
    for i in range(5):
        var rarity: CardData.Rarity = _roll_rarity()
        var card: CardData = _get_random_card_by_rarity(rarity)
        drawn_cards.append(card)
    
    pack_opened.emit(drawn_cards)
    return drawn_cards

## 重置保底计数
func reset_pity() -> void:
    _current_pity = 0
