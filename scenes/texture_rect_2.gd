extends TextureButton

@onready var ui: Node2D = $"../.."
@onready var label_2: Label = $Label2


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		SoundManager.play_click()
		print("UI sprite clicked!")
		if(ui.player.equipped_active_fish):
			get_tree().change_scene_to_file("res://scenes/fight_scene.tscn")
		else:
			label_2.visible = true
			await get_tree().create_timer(1.0).timeout
			label_2.visible = false
