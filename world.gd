extends Node2D

@export var noise_height_text : NoiseTexture2D
var noise : Noise
@onready var tile_map: TileMap = $TileMap
var source_id = 0
var water_atlas = Vector2i(16,15)
var land_atlas = Vector2i(12,11)


var width : int = 100
var height : int = 100

var noise_val_arr = []
var tile_types : Dictionary = {}

func _ready():
	noise = noise_height_text.noise
	generate_world()

func generate_world():
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noise_val :float = noise.get_noise_2d(x,y)
			if noise_val > 0.0:
				tile_map.set_cell(0, Vector2i(x,y), 0, land_atlas)
				tile_types[Vector2i(x,y)] = "land"
			elif noise_val <= 0.0:
				tile_map.set_cell(0, Vector2i(x,y), 0, water_atlas)
				tile_types[Vector2i(x,y)] = "water"
			noise_val_arr.append(noise_val)
	
	print("highest ", noise_val_arr.max())
	print("lowest ", noise_val_arr.min())

func is_water_at(cell : Vector2i) -> bool:
	return tile_types.get(cell, "land") == "water"
