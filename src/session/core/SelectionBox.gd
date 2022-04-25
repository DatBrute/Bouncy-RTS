extends Control

var start = Vector2.ZERO
var end = Vector2.ZERO
const color = Color(0, 1, 0)
const width = 3

func _process(_delta):
	update()

func _draw():
	var points = PackedVector2Array([
		Vector2(start.x, start.y),
		Vector2(start.x, end.y),
		Vector2(end.x, end.y),
		Vector2(end.x, start.y),
		Vector2(start.x, start.y)	
	])
	draw_polyline(points, color, width)
