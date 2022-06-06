extends CharacterBody2D

@export var side = 1

# <LOCAL>
var selected = false

@onready var radius = $CollisionShape2D.shape.radius

func _ready():
	var shape = $CollisionShape2D
	radius = $CollisionShape2D.shape.radius

func select():
	selected = false
	$SelectionRing.visible = true

func deselect():
	selected = false
	$SelectionRing.visible = false
