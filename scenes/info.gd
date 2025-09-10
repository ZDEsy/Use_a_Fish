extends Node2D

@onready var description: RichTextLabel = $PictureSprite/Description
@onready var picture_sprite: Sprite2D = $PictureSprite
@onready var right_button: TextureButton = $RightButton

# 📝 List of items (each with a picture + description)
var items: Array = [
	{
		"image": preload("res://assets/info/fishing.png"),
		"description": "Catch unique fish you can either equip for battle or sell for coins."
	},
	{
		"image": preload("res://assets/info/fishing_shop.png"),
		"description": "Spend your coins in the shop, that appears in the overworld, to unlock powerful upgrades."
	},
	{
		"image": preload("res://assets/info/fishing_enemies.png"),
		"description": "The longer you play, the more enemies will appear."
	},
	{
		"image": preload("res://assets/info/fishing_arena.png"),
		"description": "Fight in the arena to push back enemy spawns and climb the score ladder."
	}
]

var current_index: int = 0

func _ready() -> void:
	_show_item(current_index)

func _on_right_button_pressed() -> void:
	current_index = current_index + 1
	_show_item(current_index)

func _show_item(index: int) -> void:
	if index >= 0 and index < items.size():
		picture_sprite.texture = items[index]["image"]
		description.text = items[index]["description"]
	else:
		current_index = 0
		_show_item(current_index)
		visible = false
