extends Node2D

signal interacted
signal ShowE
signal HideE

@onready var area: Area2D = $Area2D

var player_inside: bool = false

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print("Body entered")
	if body.is_in_group("player"):
		print("Player entered")
		player_inside = true
		emit_signal("ShowE")

func _on_body_exited(body):
	print("Body exited")
	if body.is_in_group("player"):
		player_inside = false
		emit_signal("HideE")

func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"): # "interact" mapped to E in InputMap
		emit_signal("interacted")
