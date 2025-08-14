extends Node2D

@onready var ui: Node2D = $Player/UI
@onready var player: CharacterBody2D = $Player

func _on_player_fish_caught(fish) -> void:
	add_child(fish)
	print(ui.sprite_2d)
	print(ui.sprite_2d.texture)
	print(fish.texture)
	print(fish.sprite.texture)
	ui.sprite_2d = atlas_to_texture(fish.texture)
	print("FISH TEXTURE")

func atlas_to_texture(atlas_tex: AtlasTexture) -> Texture2D:
	var img = atlas_tex.atlas.get_image()
	var region = atlas_tex.region
	var sub_img = img.get_region(region)
	var tex = ImageTexture.create_from_image(sub_img)
	return tex
