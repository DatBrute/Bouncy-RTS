extends Node

const PAN_SPEED = 250
const ZOOM_SPEED = 4
const MIN_ZOOM = 0.2
const MAX_ZOOM = 5
const PAN_SCREEN_EDGE_FRACTION = 0.01

@onready var camera = $"FreeCamera"
var follow = false

var selecting = false

func _process(delta):
	camera_input(camera, delta)
	if not multiplayer.is_server():
		select_input()

func camera_input(c, delta):
	var zoom = ZOOM_SPEED * delta
	var pan = PAN_SPEED / c.zoom.x * delta
	var view =  get_viewport()
	var pos = view.get_mouse_position() / view.get_visible_rect().size
	if Input.is_action_just_released('zoom_out'):
		_zoom(c, zoom)
	if Input.is_action_just_released('zoom_in'):
		_zoom(c, -zoom)
	if Input.is_action_just_pressed('zoom_out'):
		_zoom(c, zoom)
	if pos.x <= PAN_SCREEN_EDGE_FRACTION:
		c.offset.x -= pan
	if pos.x >= 1-PAN_SCREEN_EDGE_FRACTION:
		c.offset.x += pan 
	if pos.y <= PAN_SCREEN_EDGE_FRACTION:
		c.offset.y -= pan
	if pos.y >= 1-PAN_SCREEN_EDGE_FRACTION:
		c.offset.y += pan

		
func _zoom(c, amount):
	c.zoom.x = clamp(c.zoom.x + amount, MIN_ZOOM, MAX_ZOOM)
	c.zoom.y = clamp(c.zoom.y + amount, MIN_ZOOM, MAX_ZOOM)

func select_input():
	var sb = $UI/SelectionBox
	if Input.is_action_just_pressed("select"):
		var pos = get_viewport().get_mouse_position()
		sb.start = pos
		sb.end = pos
		sb.visible = true
		selecting = true
	elif Input.is_action_just_released("select"):
		for unit in get_tree().get_nodes_in_group("unit"):
			unit.deselect()
		for unit in sb.get_units_inside():
			unit.select()
		sb.visible = false
		selecting = false
	elif(selecting):
		var pos = get_viewport().get_mouse_position()
		sb.end = pos

func _draw():
	pass
