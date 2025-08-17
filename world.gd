extends Node2D

@export var noise_height_text : NoiseTexture2D
@export var noise_environment_text : NoiseTexture2D
var noise : Noise
var environment_noise: Noise
@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $"../Player"

var water_layer = 0
var ground_layer = 1
var environment_layer = 3

var water_atlas = Vector2i(16,15)
var grass_atlas = Vector2i(12,11)
var dirt_atlas = Vector2i(8,11)

var tree_atlas_arr = [Vector2i(6,0), Vector2i(10,0)]
var house = Vector2i(4,4)
@export var house_scene: PackedScene = preload("res://scenes/House.tscn")
var placed_house = false
var dirt_tiles_arr = []
var grass_tiles_arr = []

var terrain_dirt_int = 3
var terrain_grass_int = 1

@export var width : int = 100
@export var height : int = 100
var render_range = 20  # radius around player

var tile_types : Dictionary = {}

func _ready():
	noise = noise_height_text.noise
	environment_noise = noise_environment_text.noise
	generate_world()

func _process(delta):
	if player:
		fill_infinite_water_around(player.position)

func generate_world():
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noise_val = noise.get_noise_2d(x, y)
			var environment_noise_val = environment_noise.get_noise_2d(x, y)
			var cell = Vector2i(x, y)
			
			if noise_val >= 0.0:
				if !placed_house and noise_val > 0.5:
					var house = house_scene.instantiate()
					house.position = tile_map.map_to_local(cell)
					add_child(house)

					placed_house = true
					continue 
				if noise_val > 0.2 and noise_val < 0.6 and environment_noise_val > 0.5:
					tile_map.set_cell(environment_layer, Vector2i(x,y), 0, tree_atlas_arr.pick_random())
				
				if noise_val > 0.2:
					grass_tiles_arr.append(cell)
				else:
					dirt_tiles_arr.append(cell)
				tile_types[cell] = "land"
			else:
				tile_map.set_cell(water_layer, cell, 0, water_atlas)
				tile_types[cell] = "water"
	
	# Apply terrain to land tiles
	tile_map.set_cells_terrain_connect(ground_layer, dirt_tiles_arr, terrain_dirt_int, 0)
	tile_map.set_cells_terrain_connect(ground_layer, grass_tiles_arr, terrain_grass_int, 0)

# Checks if a cell is water
func is_water_at(cell : Vector2i) -> bool:
	# Anything outside the generated land is water
	if cell.x < -width/2 or cell.x >= width/2:
		return true
	if cell.y < -height/2 or cell.y >= height/2:
		return true
	return tile_types.get(cell, "water") == "water"

# Dynamically fill water around the player
func fill_infinite_water_around(player_pos: Vector2):
	var map_pos = tile_map.local_to_map(player_pos)  # converts world coords to tile coords
	for x in range(map_pos.x - render_range, map_pos.x + render_range):
		for y in range(map_pos.y - render_range, map_pos.y + render_range):
			var cell = Vector2i(x, y)
			if tile_types.has(cell):
				continue
			tile_types[cell] = "water"
			tile_map.set_cell(water_layer, cell, 0, water_atlas)
