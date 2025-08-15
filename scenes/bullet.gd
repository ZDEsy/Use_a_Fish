extends Node2D

@export var speed: float = 400
var direction: Vector2
var damage: int

func _physics_process(delta):
	position += direction * speed * delta
