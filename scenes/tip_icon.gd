extends Node2D

# Backing variables
@export var _sprite_texture: Texture2D
@export var _label_text: String

# Exposed properties with setters that update the nodes
var sprite_texture: Texture2D:
	set(value):
		_sprite_texture = value
		if has_node("Sprite2D"):
			$Sprite2D.texture = value
	get:
		return _sprite_texture

var label_text: String:
	set(value):
		_label_text = value
		if has_node("Label"):
			$Label.text = value
	get:
		return _label_text

func _ready():
	# Apply initial values
	if has_node("Sprite2D"):
		$Sprite2D.texture = sprite_texture
	else:
		print("Warning: Sprite2D node not found!")

	if has_node("Label"):
		$Label.text = label_text
	else:
		print("Warning: Label node not found!")
