extends CharacterBody2D

@export var speed = 0
@export var climb_speed_mult = 1.0
@export var size = 10
@export var attack_range = 0
@export var growth_mult = 1.0
@export var knockback_mult = 1.0

# <LOCAL>
var selected = false

func _ready():
	pass 

func select():
	selected = false
	$SelectionRing.visible = true

func deselect():
	selected = false
	$SelectionRing.visible = false
