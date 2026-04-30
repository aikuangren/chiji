class_name SupplySpawner

const ITEM_SCENE = preload("res://scenes/supply_crate.tscn")
const MAP_SIZE = MapData.MAP_SIZE
const SPAWN_MARGIN = 100
const MIN_DISTANCE_BETWEEN_ITEMS = 150

var spawned_items: Array = []

func spawn_supplies(total_count: int = 30) -> Array:
	var items: Array = []
	var attempts = 0
	var max_attempts = total_count * 10
	
	while items.size() < total_count and attempts < max_attempts:
		attempts += 1
		
		var pos = _get_random_map_position()
		
		if not _is_position_valid(pos, items):
			continue
		
		var region = MapData.get_region_at(pos.x, pos.y)
		var density = SupplyData.REGION_SPAWN_DENSITY[region]
		
		if randf() > density * 10:
			continue
		
		var item = _create_item(pos)
		items.append(item)
	
	spawned_items = items
	return items

func spawn_supplies_in_region(region_type: MapData.RegionType, count: int) -> Array:
	var items: Array = []
	var region = _get_region_data(region_type)
	
	for i in range(count):
		var pos = _get_random_position_in_circle(
			Vector2(region[0], region[1]),
			region[2] * 0.8
		)
		
		if not _is_position_valid(pos, items):
			continue
		
		var item = _create_item(pos)
		items.append(item)
	
	spawned_items.append_array(items)
	return items

func _get_random_map_position() -> Vector2:
	var range_max = MAP_SIZE - SPAWN_MARGIN
	return Vector2(
		randf_range(-range_max, range_max),
		randf_range(-range_max, range_max)
	)

func _get_random_position_in_circle(center: Vector2, radius: float) -> Vector2:
	var angle = randf() * TAU
	var r = sqrt(randf()) * radius
	return center + Vector2(cos(angle), sin(angle)) * r

func _is_position_valid(pos: Vector2, existing_items: Array) -> bool:
	for item in existing_items:
		if item is Node2D:
			if pos.distance_to(item.position) < MIN_DISTANCE_BETWEEN_ITEMS:
				return false
	return true

func _create_item(pos: Vector2) -> Node2D:
	var item = ITEM_SCENE.instantiate()
	item.position = pos
	item.item_type = SupplyData.random_item_type()
	
	var scale = randf_range(0.8, 1.2)
	item.scale = Vector2(scale, scale)
	
	return item

func _get_region_data(region_type: MapData.RegionType) -> Array:
	for region in MapData.REGION_LAYOUT:
		if region[3] == region_type:
			return region
	return [0, 0, 400, MapData.RegionType.PLAINS]

func clear_all():
	for item in spawned_items:
		if item is Node2D and is_instance_valid(item):
			item.queue_free()
	spawned_items.clear()

func get_nearest_item(pos: Vector2) -> Node2D:
	var nearest: Node2D = null
	var min_dist = INF
	
	for item in spawned_items:
		if item is Node2D and is_instance_valid(item):
			var dist = pos.distance_to(item.position)
			if dist < min_dist:
				min_dist = dist
				nearest = item
	
	return nearest
