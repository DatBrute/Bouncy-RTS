extends "Selectable.gd"

@export var speed = 0
@export var move_target = null

#@export var climb_speed_mult = 1.0
#@export var size = 10
#@export var attack_range = 0
#@export var growth_mult = 1.0
#@export var knockback_mult = 1.0

func _ready():
	radius = $CollisionShape2D.shape.radius
	if(side == 1):
		$Team1Ring.visible = true
	else:
		$Team2Ring.visible = true

func _physics_process(_delta):
	if Input.is_action_pressed("act") and selected:
		global_position = get_global_mouse_position()
