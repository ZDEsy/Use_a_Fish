# player_state.gd
extends Node

# Player stats you want to preserve
var health: int = 100
var mana: int = 50
var position: Vector2 = Vector2.ZERO
var equipped_active_fish

# Optional: reset function
func reset():
	health = 100
	mana = 50
	position = Vector2.ZERO
