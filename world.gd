extends Node2D

@export var noise_height_text : NoiseTexture2D
var noise : Noise
@onready var tile_map: TileMap = $TileMap
var source_id = 0

var water_layer = 0
var ground_1_layer = 1
var ground_2_layer = 2

var water_atlas = Vector2i(16,15)
var grass_atlas = Vector2i(12,11)
var dirt_atlas = Vector2i(8,11)

var dirt_tiles_arr = []
var terrain_dirt_int = 3
var terrain_grass_int = 1

var grass_tiles_arr = []


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
			if noise_val >= 0.0:
				if noise_val > 0.2:
					grass_tiles_arr.append(Vector2i(x,y))
				else:
					dirt_tiles_arr.append(Vector2i(x,y))
				tile_types[Vector2i(x,y)] = "land"
			else:
				tile_map.set_cell(water_layer, Vector2i(x,y), 0, water_atlas)
				tile_types[Vector2i(x,y)] = "water"
			noise_val_arr.append(noise_val)
	tile_map.set_cells_terrain_connect(ground_1_layer, dirt_tiles_arr, terrain_dirt_int, 0)
	tile_map.set_cells_terrain_connect(ground_1_layer, grass_tiles_arr, terrain_grass_int, 0)

func is_water_at(cell : Vector2i) -> bool:
	return tile_types.get(cell, "land") == "water"
