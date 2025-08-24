extends Node2D

@onready var label: Label = $Label
@onready var fullscreen_checkbox: CheckBox = $CheckBox
@onready var music_checkbox: CheckBox = $CheckBox2
@onready var sfx_checkbox: CheckBox = $CheckBox3

func _on_fullscreen_toggled(pressed: bool):
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if pressed else DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)

func _on_music_toggled(pressed: bool):
	MusicManager.set_music_enabled(pressed)

func _on_sfx_toggled(pressed: bool) -> void:
	mute_all(pressed)

func mute_all(mute: bool) -> void:
	var master_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_idx, mute)
