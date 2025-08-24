extends Node2D

@onready var texture_button: TextureButton = $TextureButton
@onready var label_2: Label = $Label2

func _ready() -> void:
	label_2.text = "Highscore: " + str(GameData.high_score)

func _on_texture_button_pressed() -> void:
	print("pressing")
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")  # reloads the game
	SoundManager.play_click()
