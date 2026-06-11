# chiji

`chiji` 是一个使用 Godot 4.6 开发的 2D 俯视角生存射击游戏项目。当前版本围绕关卡生存、敌人清理、补给拾取、科幻风 HUD 和瓦片战斗地图展开。

## 当前内容

- 主菜单进入战斗关卡
- WASD / 方向键移动
- 远程射击、近战攻击和基础弹幕逻辑
- 射击怪、自爆怪等敌人生成与击杀统计
- 补给箱和道具拾取
- 科幻风战斗 HUD、武器栏、技能按钮、迷你地图和任务面板
- 32 x 32 战术瓦片地图
- 地面 / 阻挡两类瓦片
- 玩家、敌人、道具生成会避开阻挡区域

## 运行方式

1. 安装 Godot 4.6 或更新的 Godot 4.x 版本。
2. 使用 Godot 打开项目根目录。
3. 运行主场景：

```text
res://scenes/main_menu.tscn
```

项目入口已经配置在 `project.godot` 中，打开项目后可直接点击运行。

## 操作

| 操作 | 按键 |
| --- | --- |
| 移动 | W / A / S / D 或方向键 |
| 射击 | O |
| 近战技能 | K |
| 交互 | E |
| 暂停 / 返回菜单 | HUD 暂停按钮 |

## 目录结构

```text
assets/                 游戏素材和 Godot 导入资源
assets/maps/            地图和瓦片素材
assets/ui/sci_fi/       科幻 HUD 裁切素材
scenes/                 Godot 场景
scripts/                GDScript 游戏逻辑
scripts/card_game/      卡牌玩法相关脚本
project.godot           Godot 项目配置
```

## 关键脚本

- `scripts/game.gd`：战斗主流程、关卡初始化、胜负判断、UI 数据刷新
- `scripts/player.gd`：玩家移动、射击、近战、生命和 Buff
- `scripts/enemy.gd`：敌人 AI、受击、死亡和攻击行为
- `scripts/enemy_spawner.gd`：敌人生成，避开玩家和地图阻挡
- `scripts/supply_spawner.gd`：补给生成，避开地图阻挡
- `scripts/map_tile_data.gd`：瓦片地图数据、阻挡格判断、世界坐标转换
- `scripts/map_renderer.gd`：战斗地图绘制
- `scripts/map_collision_grid.gd`：根据瓦片阻挡数据生成地形碰撞
- `scripts/sci_fi_hud.gd`：战斗 HUD 布局和绘制
- `scripts/sci_fi_frame.gd`：科幻面板边框绘制

## 地图说明

当前战斗地图采用简单的 FC 风格瓦片方案：

- 地面瓦片：可行走
- 阻挡瓦片：不可行走，会自动生成碰撞

地图数据集中在 `scripts/map_tile_data.gd`。如果要调整战斗空间，只需要修改 `BLOCKED_RECTS` 中的矩形区域；渲染、碰撞、敌人生成和道具生成都会同步使用这份数据。

## 开发说明

- 删除文件前需要先确认，避免误删 Godot 导入文件或用户素材。
- Godot 的 `.import` 文件需要和对应素材一起提交。
- 新增输入建议写入 `project.godot` 的 Input Map。
- 玩家和 NPC 的移动逻辑应放在 `_physics_process` 中。
- 地图阻挡相关逻辑优先复用 `MapTileData`，避免视觉地图和碰撞规则不一致。

## 当前状态

项目还在原型完善阶段，UI、地图布局、敌人行为和道具系统都可以继续迭代。当前重点是先保证战斗场景可玩、可调，再逐步增加更精细的地图装饰和角色表现。
