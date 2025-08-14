extends Node

class_name FishManager

var rarity_weights := {
	"common": 60.0,
	"rare": 35.0,
	"epic": 4.0,
	"legendary": 1.0
}

var fish := []

var dir = DirAccess.open("res://scenes/fish")

func _ready() -> void:
	if dir == null: print("Could not open"); return
	dir.list_dir_begin()
	for file: String in dir.get_files():
		var resource := load(dir.get_current_dir() + "/" + file)
		fish.append(resource)
		print(resource.instantiate().fish_name)

func get_all_fish() -> Array:
	return fish
