extends Node2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ui_circle: Sprite2D = $UiCircle
@onready var ui_circle_2: Sprite2D = $UiCircle2
@onready var texture_rect: TextureRect = $TextureRect
@onready var new_fish_sprite: Sprite2D = $TextureRect/NewFishSprite
@onready var player: CharacterBody2D = $".."

var fish_to_be_picked


func _on_player_fish_caught(fish: Variant) -> void:
	fish_to_be_picked = fish
	texture_rect.visible = true
	new_fish_sprite.texture = fish.texture

func _on_texture_rect_fish_picked() -> void:
	texture_rect.visible = false
	new_fish_sprite.texture = null
	player.equipped_active_fish = fish_to_be_picked
	PlayerState.equipped_active_fish = player.equipped_active_fish


func _on_player_changed_mode() -> void:
	if(player.player_mode == player.PlayerMode.FISHING || player.equipped_active_fish == null):
		sprite_2d.scale = Vector2(1, 1)
		sprite_2d.texture = load("res://assets/player/fishing_rod.png")
		player.fish_sprite.texture = null
	else:
		sprite_2d.scale = Vector2(0.5, 0.5)
		sprite_2d.texture = player.equipped_active_fish.texture
		player.fish_sprite.texture = player.equipped_active_fish.texture
