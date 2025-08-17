extends StaticBody2D

signal interacted

@onready var area: Area2D = $Area2D

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

var player_inside: bool = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"): # "interact" mapped to E in InputMap
		emit_signal("interacted")
