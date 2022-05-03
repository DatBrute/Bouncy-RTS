extends CharacterBody2D

@export var speed = 0
@export var climb_speed_mult = 1.0
@export var size = 10
@export var attack_range = 0
@export var growth_mult = 1.0
@export var knockback_mult = 1.0

var L0_selected = false

func _ready():
	pass 

func select():
	L0_selected = false
	$SelectionRing.visible = true

func deselect():
	L0_selected = false
	$SelectionRing.visible = false
