extends Node2D

@onready var game_ui: Node2D = $GameUI
@onready var ui_circle: Sprite2D = $GameUI/UiCircle
@onready var sprite_2d: Sprite2D = $GameUI/Sprite2D
@onready var texture_rect_2: TextureButton = $GameUI/TextureRect2
@onready var label: Label = $GameUI/TextureRect2/Label
@onready var shop_ui: Control = $GameUI/ShopUI
@onready var caught_ui: Node2D = $GameUI/CaughtUI
@onready var new_fish_sprite: Sprite2D = $GameUI/CaughtUI/NewFishSprite
@onready var health: Node2D = $GameUI/Health
@onready var main_menu: Node2D = $MainMenu
@onready var camera_2d: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $".."
@onready var first_tip: Node2D = $GameUI/FirstTip
@onready var second_tip: Node2D = $GameUI/SecondTip


var fish_to_be_picked


func _on_player_fish_caught(fish: Variant) -> void:
	fish_to_be_picked = fish
	caught_ui.rarity_label.text = fish.rarity
	caught_ui.name_label.text = fish.fish_name
	caught_ui.show_caught_ui()
	new_fish_sprite.texture = fish.texture

func _on_player_changed_mode() -> void:
	if(player.player_mode == player.PlayerMode.FISHING || player.equipped_active_fish == null):
		sprite_2d.scale = Vector2(1, 1)
		sprite_2d.texture = load("res://assets/player/fishing_rod.png")
		player.fish_sprite.texture = null
		first_tip.sprite_texture = load("res://assets/left_click.png")
		first_tip.label_text = "cast"
		second_tip.sprite_texture = null
		second_tip.label_text = ""
	else:
		sprite_2d.scale = Vector2(0.5, 0.5)
		sprite_2d.texture = player.equipped_active_fish.texture
		player.fish_sprite.texture = player.equipped_active_fish.texture
		first_tip.sprite_texture = load("res://assets/left_click.png")
		first_tip.label_text = "attack"
		if(player.equipped_active_fish != null && player.equipped_active_fish.has_right_click):
			second_tip.sprite_texture = load("res://assets/right_click.png")
			second_tip.label_text = "effect"


func _on_caught_ui_use_pressed() -> void:
	caught_ui.visible = false
	new_fish_sprite.texture = null
	player.equipped_active_fish = fish_to_be_picked
	PlayerState.equipped_active_fish = player.equipped_active_fish
	
	SoundManager.play_click()


func _on_caught_ui_sell_pressed() -> void:
	caught_ui.visible = false
	new_fish_sprite.texture = null
	GameData.add_coins(10)
	SoundManager.play_click()
