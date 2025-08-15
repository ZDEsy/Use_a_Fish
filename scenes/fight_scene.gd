extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var area_2d: Area2D = $Area2D
@onready var spawn_timer: Timer = $SpawnTimer


@onready var enemy_scenes = [
	preload("res://scenes/enemies/bat.tscn")
]

func _ready():
	player.equipped_active_fish = PlayerState.equipped_active_fish
	randomize()
	spawn_timer.start()

func spawn_random_enemy():
	# Pick a random enemy scene
	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = enemy_scene.instantiate()

	# Get the CollisionShape2D of the Area2D
	var shape = area_2d.get_node("CollisionShape2D").shape
	if shape is RectangleShape2D:
		var rect_position = area_2d.global_position - shape.extents
		var rect_size = shape.extents * 2

		# Random position inside rectangle
		var x = randf_range(rect_position.x, rect_position.x + rect_size.x)
		var y = randf_range(rect_position.y, rect_position.y + rect_size.y)
		enemy.position = Vector2(x, y)
		add_child(enemy)
	else:
		push_error("Area2D must have a RectangleShape2D collision shape")


func _on_spawn_timer_timeout() -> void:
	print("enemy spawned")
	spawn_random_enemy()
