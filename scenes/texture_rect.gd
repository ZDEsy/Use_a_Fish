extends TextureRect

signal fish_picked

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("UI sprite clicked!")
		fish_picked.emit()
		get_viewport().set_input_as_handled()
