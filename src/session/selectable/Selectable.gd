extends CharacterBody2D

@export var team = 0

# <LOCAL>
var selected = false
@onready var radius = $CollisionShape2D.shape.radius

func _ready():
	pass 

func select():
	selected = false
	$SelectionRing.visible = true

func deselect():
	selected = false
	$SelectionRing.visible = false
