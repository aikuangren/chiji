extends Node2D

const GRID_SIZE = 64
const GRID_COLOR = Color(0.22, 0.42, 0.22, 0.5)
const MAP_SIZE = 2000

func _draw():
	var x = -MAP_SIZE
	while x <= MAP_SIZE:
		draw_line(Vector2(x, -MAP_SIZE), Vector2(x, MAP_SIZE), GRID_COLOR, 1.0)
		x += GRID_SIZE
	
	var y = -MAP_SIZE
	while y <= MAP_SIZE:
		draw_line(Vector2(-MAP_SIZE, y), Vector2(MAP_SIZE, y), GRID_COLOR, 1.0)
		y += GRID_SIZE
