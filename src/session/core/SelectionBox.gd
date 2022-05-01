extends Control

var start = Vector2.ZERO
var end = Vector2.ZERO
const color = Color(0, 1, 0)
const width = 3

func _process(_delta):
	if not multiplayer.is_server():
		update()
		get_units_inside()

func _draw():
	var points = PackedVector2Array([
		Vector2(start.x, start.y),
		Vector2(start.x, end.y),
		Vector2(end.x, end.y),
		Vector2(end.x, start.y),
		Vector2(start.x, start.y)	
	])
	draw_polyline(points, color, width)

func get_units_inside():
	var vp = get_viewport()
	var offset =  vp.get_camera_2d().get_camera_screen_center() - vp.get_visible_rect().size/2
	var a = start + offset
	var b = end + offset
	var x_min = min(a.x, b.x)
	var x_max = max(a.x, b.x)
	var y_min = min(a.y, b.y)
	var y_max = max(a.y, b.y)
	for unit in get_tree().get_nodes_in_group("Unit"):
		var p = unit.global_position
		if(p.x >= x_min and p.x <= x_max and p.y >= y_min and p.y <= y_max):
			print(unit)
