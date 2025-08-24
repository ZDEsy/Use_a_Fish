extends Node2D
@onready var rarity_label: Label = $RarityLabel
@onready var name_label: Label = $NameLabel


signal use_pressed
signal sell_pressed

var input_locked: bool = false

func _on_sell_button_pressed() -> void:
	if input_locked:
		return
	sell_pressed.emit()

func _on_use_button_pressed() -> void:
	if input_locked:
		return
	use_pressed.emit()

func show_caught_ui() -> void:
	visible = true
	_lock_input_for(0.5)

func _lock_input_for(duration: float) -> void:
	input_locked = true
	await get_tree().create_timer(duration).timeout
	input_locked = false
