extends TextureRect



func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("UI sprite clicked!")
		get_tree().change_scene_to_file("res://scenes/fight_scene.tscn")
