extends Node

@onready var camera = $"FreeCamera"
var follow = false

const PAN_SPEED = 1000
const ZOOM_SPEED = 4
const MIN_ZOOM = 0.2
const MAX_ZOOM = 5

func _ready():
	print(">>C0R3 0NL1N3<<")
	print(get_multiplayer_authority())
	
func camera_input(c, delta):
	var zoom = ZOOM_SPEED * delta
	var pan = PAN_SPEED / c.zoom.x * delta
	if Input.is_action_just_released('zoom_out'):
		_zoom(c, zoom)
	if Input.is_action_just_released('zoom_in'):
		_zoom(c, -zoom)
	if Input.is_action_pressed("ui_left"):
		c.offset.x -= pan
	if Input.is_action_pressed('ui_right'):
		c.offset.x += pan 
	if Input.is_action_pressed("ui_up"):
		c.offset.y -= pan
	if Input.is_action_pressed("ui_down"):
		c.offset.y += pan

		
func _zoom(c, amount):
	c.zoom.x = clamp(c.zoom.x + amount, MIN_ZOOM, MAX_ZOOM)
	c.zoom.y = clamp(c.zoom.y + amount, MIN_ZOOM, MAX_ZOOM)

func _process(delta):
	camera_input(camera, delta)
	test_rpc()
	
@rpc
func test_rpc():
	print("blah")

