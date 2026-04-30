class_name ObstacleSpawner

const SPAWN_MARGIN = 50
const MIN_DISTANCE_BETWEEN_OBSTACLES = 80
const PLAYER_SPAWN_CLEAR_RADIUS = 200

enum ObstacleType {
	TREE_SMALL,
	TREE_LARGE,
	ROCK_SMALL,
	BUSH,
	DEBRIS_SMALL,
	DEBRIS_LARGE,
	WALL_REMAIN,
	BUILDING_RUIN,
	VEHICLE_WRECK,
	SAND_DUNE,
	ROCK_FORMATION,
	CACTUS,
	BOULDER,
	STUMP
}

const OBSTACLE_CONFIGS = {
	ObstacleType.TREE_SMALL: {"name": "小树", "region": 0, "color": Color(0.2, 0.4, 0.15), "size": Vector2(25, 25), "collision_size": Vector2(20, 20), "spawn_weight": 40, "collision_type": "circle"},
	ObstacleType.TREE_LARGE: {"name": "大树", "region": 0, "color": Color(0.15, 0.35, 0.12), "size": Vector2(45, 45), "collision_size": Vector2(35, 35), "spawn_weight": 20, "collision_type": "circle"},
	ObstacleType.ROCK_SMALL: {"name": "小石头", "region": 0, "color": Color(0.4, 0.38, 0.35), "size": Vector2(18, 15), "collision_size": Vector2(15, 12), "spawn_weight": 15, "collision_type": "rect"},
	ObstacleType.BUSH: {"name": "灌木", "region": 0, "color": Color(0.25, 0.45, 0.2), "size": Vector2(30, 25), "collision_size": Vector2(25, 20), "spawn_weight": 25, "collision_type": "circle"},
	ObstacleType.DEBRIS_SMALL: {"name": "小碎石堆", "region": 2, "color": Color(0.45, 0.42, 0.4), "size": Vector2(35, 30), "collision_size": Vector2(30, 25), "spawn_weight": 25, "collision_type": "rect"},
	ObstacleType.DEBRIS_LARGE: {"name": "大碎石堆", "region": 2, "color": Color(0.4, 0.38, 0.36), "size": Vector2(60, 50), "collision_size": Vector2(55, 45), "spawn_weight": 15, "collision_type": "rect"},
	ObstacleType.WALL_REMAIN: {"name": "残墙", "region": 2, "color": Color(0.5, 0.48, 0.45), "size": Vector2(80, 25), "collision_size": Vector2(75, 20), "spawn_weight": 20, "collision_type": "rect"},
	ObstacleType.BUILDING_RUIN: {"name": "废墟建筑", "region": 2, "color": Color(0.4, 0.38, 0.35), "size": Vector2(120, 100), "collision_size": Vector2(110, 90), "spawn_weight": 10, "collision_type": "rect"},
	ObstacleType.VEHICLE_WRECK: {"name": "废弃车辆", "region": 2, "color": Color(0.35, 0.32, 0.3), "size": Vector2(70, 40), "collision_size": Vector2(65, 35), "spawn_weight": 15, "collision_type": "rect"},
	ObstacleType.SAND_DUNE: {"name": "沙丘", "region": 3, "color": Color(0.6, 0.52, 0.35), "size": Vector2(55, 30), "collision_size": Vector2(45, 25), "spawn_weight": 30, "collision_type": "circle"},
	ObstacleType.ROCK_FORMATION: {"name": "岩层", "region": 3, "color": Color(0.55, 0.48, 0.4), "size": Vector2(65, 45), "collision_size": Vector2(55, 38), "spawn_weight": 25, "collision_type": "rect"},
	ObstacleType.CACTUS: {"name": "仙人掌", "region": 3, "color": Color(0.3, 0.5, 0.25), "size": Vector2(20, 40), "collision_size": Vector2(15, 35), "spawn_weight": 35, "collision_type": "circle"},
	ObstacleType.BOULDER: {"name": "巨石", "region": 1, "color": Color(0.5, 0.48, 0.45), "size": Vector2(40, 35), "collision_size": Vector2(35, 30), "spawn_weight": 35, "collision_type": "circle"},
	ObstacleType.STUMP: {"name": "树桩", "region": 1, "color": Color(0.4, 0.3, 0.2), "size": Vector2(25, 20), "collision_size": Vector2(20, 15), "spawn_weight": 25, "collision_type": "circle"}
}

const REGION_OBSTACLE_DENSITY = {
	0: 0.04,
	2: 0.05,
	1: 0.015,
	3: 0.02
}

var spawned_obstacles: Array = []
var obstacle_positions: Array = []

func spawn_obstacles(obstacles_parent: Node2D, player_pos: Vector2, region_type: int):
	var bounds = _get_region_bounds(region_type)
	var min_x = bounds[0]
	var max_x = bounds[1]
	var min_y = bounds[2]
	var max_y = bounds[3]
	
	var area = (max_x - min_x) * (max_y - min_y)
	var density = REGION_OBSTACLE_DENSITY.get(region_type, 0.02)
	var target_count = int(area * density / 10000)
	var attempts = target_count * 10
	var spawned = 0
	
	for i in range(attempts):
		if spawned >= target_count:
			break
		
		var pos = Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)
		
		if pos.distance_to(player_pos) < PLAYER_SPAWN_CLEAR_RADIUS:
			continue
		
		var too_close = false
		for existing_pos in obstacle_positions:
			if pos.distance_to(existing_pos) < MIN_DISTANCE_BETWEEN_OBSTACLES:
				too_close = true
				break
		
		if too_close:
			continue
		
		var obstacle_type = _select_obstacle_type(region_type)
		if obstacle_type == -1:
			continue
		
		var obstacle = _create_obstacle(obstacle_type, pos)
		if obstacle:
			obstacles_parent.add_child(obstacle)
			spawned_obstacles.append(obstacle)
			obstacle_positions.append(pos)
			spawned += 1

func _select_obstacle_type(region_type: int) -> int:
	var region_types = []
	for obs_type in OBSTACLE_CONFIGS.keys():
		var config = OBSTACLE_CONFIGS[obs_type]
		if config["region"] == region_type:
			for j in range(config["spawn_weight"]):
				region_types.append(obs_type)
	
	if region_types.is_empty():
		return -1
	
	return region_types[randi() % region_types.size()]

func _create_obstacle(type: ObstacleType, pos: Vector2) -> Node2D:
	var config = OBSTACLE_CONFIGS[type]
	var node = StaticBody2D.new()
	node.position = pos
	
	var collision_shape = CollisionShape2D.new()
	var shape
	
	if config["collision_type"] == "circle":
		shape = CircleShape2D.new()
		shape.radius = config["collision_size"].x / 2.0
	else:
		shape = RectangleShape2D.new()
		shape.size = config["collision_size"]
	
	collision_shape.shape = shape
	node.add_child(collision_shape)
	
	var sprite = ColorRect.new()
	sprite.size = config["size"]
	sprite.color = config["color"]
	sprite.custom_minimum_size = config["size"]
	sprite.position = -config["size"] / 2.0
	node.add_child(sprite)
	
	node.z_index = 20
	return node

# Returns [min_x, max_x, min_y, max_y]
func _get_region_bounds(region_type: int) -> Array:
	match region_type:
		0: return [-600.0, -400.0, -400.0, 400.0]  # Forest (left-top)
		1: return [500.0, 700.0, -450.0, -250.0]   # Plains (right-top)
		2: return [-550.0, -350.0, 400.0, 600.0]   # City (left-bottom)
		3: return [450.0, 650.0, 350.0, 550.0]     # Desert (right-bottom)
	return [-600.0, 700.0, -450.0, 600.0]

func clear_all():
	for obs in spawned_obstacles:
		if obs is Node2D and is_instance_valid(obs):
			obs.queue_free()
	spawned_obstacles.clear()
	obstacle_positions.clear()
