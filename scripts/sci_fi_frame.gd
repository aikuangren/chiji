extends Control

class_name SciFiFrame

var bg_color: Color = Color(0.02, 0.055, 0.03, 0.82)
var border_color: Color = Color(0.18, 0.82, 0.2, 0.82)
var glow_color: Color = Color(0.38, 1.0, 0.26, 0.95)
var grid_color: Color = Color(0.8, 1.0, 0.75, 0.055)
var cut: float = 14.0
var show_grid: bool = true
var corner_length: float = 28.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 2 or h <= 2:
		return
	
	var shape := PackedVector2Array([
		Vector2(cut, 0),
		Vector2(w - cut, 0),
		Vector2(w, cut),
		Vector2(w, h - cut),
		Vector2(w - cut, h),
		Vector2(cut, h),
		Vector2(0, h - cut),
		Vector2(0, cut),
	])
	
	var shadow := PackedVector2Array()
	for p in shape:
		shadow.append(p + Vector2(3, 4))
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.28))
	draw_colored_polygon(shape, bg_color)
	
	if show_grid:
		var step := 26.0
		var x := step
		while x < w:
			draw_line(Vector2(x, cut), Vector2(x, h - cut), grid_color, 1.0)
			x += step
		var y := step
		while y < h:
			draw_line(Vector2(cut, y), Vector2(w - cut, y), grid_color, 1.0)
			y += step
	
	var closed := shape.duplicate()
	closed.append(shape[0])
	draw_polyline(closed, Color(0, 0, 0, 0.55), 5.0)
	draw_polyline(closed, border_color, 2.0)
	draw_polyline(closed, Color(glow_color.r, glow_color.g, glow_color.b, 0.18), 6.0)
	_draw_corner_accents(w, h)

func _draw_corner_accents(w: float, h: float) -> void:
	var c := glow_color
	var l := corner_length
	var inset := 5.0
	
	draw_line(Vector2(inset, cut), Vector2(inset, l), c, 2.0)
	draw_line(Vector2(cut, inset), Vector2(l, inset), c, 2.0)
	draw_line(Vector2(w - inset, cut), Vector2(w - inset, l), c, 2.0)
	draw_line(Vector2(w - cut, inset), Vector2(w - l, inset), c, 2.0)
	
	draw_line(Vector2(inset, h - cut), Vector2(inset, h - l), c, 2.0)
	draw_line(Vector2(cut, h - inset), Vector2(l, h - inset), c, 2.0)
	draw_line(Vector2(w - inset, h - cut), Vector2(w - inset, h - l), c, 2.0)
	draw_line(Vector2(w - cut, h - inset), Vector2(w - l, h - inset), c, 2.0)
