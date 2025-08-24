extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var spawn_timer: Timer = $SpawnTimer
@onready var ui: Node2D = $Player/UI
@onready var main_menu: Node2D = ui.main_menu
@onready var game_ui: Node2D = ui.game_ui
@onready var highscore_label: Label = main_menu.label

@onready var enemy_scenes = [
	preload("res://scenes/enemies/bat.tscn"),
	preload("res://scenes/enemies/wolf.tscn"),
	preload("res://scenes/enemies/knight.tscn"),
	preload("res://scenes/enemies/witch.tscn"),
	preload("res://scenes/enemies/golem.tscn")
]

# Spawn rate control
var spawn_rate: float = 120.0      
var spawn_acceleration: float = 0.5  

# Spawn area relative to player
var spawn_distance_x: float = 400  
var spawn_distance_y: float = 300  

var game_started: bool = false

func _ready():
	MusicManager.play_music(preload("res://sounds/Retro Music - ABMU - ChipWave 01.ogg"))
	GameData.load_game()
	randomize()
	
	# Show main menu
	main_menu.visible = true
	game_ui.visible = false
	
	# Process input even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Pause game logic until started
	get_tree().paused = true
	
	highscore_label.text = str("Highscore: ", GameData.high_score)
	
	spawn_timer.wait_time = spawn_rate
	spawn_timer.stop()  # don't start until game begins

func _unhandled_input(event: InputEvent) -> void:
	if not game_started:
		if event.is_pressed():
			_start_game()

func _start_game() -> void:
	SoundManager.play_click()
	main_menu.visible = false
	game_ui.visible = true
	
	# Resume game logic
	get_tree().paused = false
	spawn_timer.start()
	game_started = true
	
	# Disable main scene input to save memory
	set_process_input(false)
	set_process_unhandled_input(false)

func _on_spawn_timer_timeout() -> void:
	if not game_started:
		return
	
	spawn_random_enemy()
	
	# Gradually increase spawn rate
	spawn_timer.wait_time = max(0.5, spawn_timer.wait_time * spawn_acceleration)
	spawn_acceleration = min(spawn_acceleration + 0.5, 1.0)
	spawn_timer.start()

func spawn_random_enemy():
	if enemy_scenes.size() == 0:
		return

	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = enemy_scene.instantiate()

	var x = randf_range(player.global_position.x - spawn_distance_x, player.global_position.x + spawn_distance_x)
	var y = randf_range(player.global_position.y - spawn_distance_y, player.global_position.y + spawn_distance_y)
	enemy.position = Vector2(x, y)
	add_child(enemy)
	

func _process(delta: float) -> void:
	ui.health.label.text = str(GameData.health)
