extends Node2D

# -----------------------------
# Scene references (keep names)
# -----------------------------
@onready var player: CharacterBody2D = $Player
@onready var spawn_area: Area2D = $Area2D          # Rectangle area where enemies can spawn
@onready var spawn_timer: Timer = $SpawnTimer      # ticks to spawn enemies DURING a wave
@onready var wave_timer:  Timer = $WaveTimer       # counts down the DURATION of a wave
@onready var game_over: Node2D = $GameOver

# --------------------------------
# Enemy scenes (tiers by difficulty)
# Fill these with your enemy scenes
# --------------------------------
@export var enemy_tier1: Array[PackedScene] = [preload("res://scenes/enemies/bat.tscn"), preload("res://scenes/enemies/wolf.tscn")]
@export var enemy_tier2: Array[PackedScene] = [preload("res://scenes/enemies/knight.tscn"), preload("res://scenes/enemies/witch.tscn")]
@export var enemy_tier3: Array[PackedScene] = [preload("res://scenes/enemies/golem.tscn")]

# -----------------------------
# Wave configuration
# -----------------------------
const TOTAL_WAVES := 10                      # waves per “set”
@export var base_wave_duration: float = 30.0 # seconds each wave lasts (time-based, not kill-based)
@export var base_enemies_per_wave: int = 10   # starting enemy count in wave 1
@export var enemies_growth_per_wave: int = 2 # +2 enemies each next wave
@export var set_enemy_growth: float = 0.25   # +25% enemies for each completed set of 10

# Optional small pause between waves (set to 0 for no pause)
@export var inter_wave_delay: float = 1.0

# -----------------------------
# Runtime state
# -----------------------------
var current_wave: int = 0
var set_index: int = 0              # how many 10-wave sets already completed (persistent)
var target_spawns_this_wave: int = 0
var spawned_this_wave: int = 0
var wave_running: bool = false

# Signals you can hook if you want UI feedback
signal wave_started(wave: int)
signal wave_ended(wave: int)
signal all_waves_completed(set_index: int)

func _ready() -> void:
	MusicManager.play_music(preload("res://sounds/Music_Loop_6_Full.ogg"))
	player.equipped_active_fish = PlayerState.equipped_active_fish
	player.player_mode = player.PlayerMode.COMBAT
	if player.equipped_active_fish:
		player.fish_sprite.texture = player.equipped_active_fish.texture

	# Load persistent “set progression” if you added it to GameData (optional)
	var gd_set = GameData.get("wave_set_index")
	if gd_set != null:
		set_index = int(gd_set)

	# Connect timers (can also connect in the editor)
	spawn_timer.timeout.connect(_on_spawn_timer_tick)
	wave_timer.timeout.connect(_on_wave_timer_timeout)

	# Start the 10-wave run
	_start_next_wave()

# --------------------------------------------
# WAVE FLOW
# --------------------------------------------
func _start_next_wave() -> void:
	current_wave += 1
	GameData.wave_count = current_wave

	# After the last wave: wait until all enemies are cleared
	if current_wave > TOTAL_WAVES:
		if get_tree().get_nodes_in_group("enemies").is_empty():
			_on_all_waves_completed()
		else:
			call_deferred("_wait_for_enemies_cleared")
		return

	# -------------------------
	# Start a normal wave
	# -------------------------
	var duration: float = base_wave_duration
	target_spawns_this_wave = _enemies_for_wave(current_wave, set_index)
	spawned_this_wave = 0

	# Configure timers
	wave_running = true
	wave_timer.wait_time = duration
	wave_timer.start()

	var spawn_interval: float = max(0.2, duration / float(max(1, target_spawns_this_wave)))
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()

	emit_signal("wave_started", current_wave)
	print("Wave", current_wave, "started. Spawning", target_spawns_this_wave, "enemies in", duration, "sec.")



func _wait_for_enemies_cleared() -> void:
	# Called repeatedly until no enemies remain
	if get_tree().get_nodes_in_group("enemies").is_empty():
		_on_all_waves_completed()
	else:
		await get_tree().process_frame
		_wait_for_enemies_cleared()


func _on_wave_timer_timeout() -> void:
	wave_running = false
	spawn_timer.stop()
	emit_signal("wave_ended", current_wave)
	print("Wave", current_wave, "ended.")

	# Optional small gap
	if inter_wave_delay > 0.0:
		await get_tree().create_timer(inter_wave_delay).timeout

	_start_next_wave()


func _on_spawn_timer_tick() -> void:
	if not wave_running:
		return
	if spawned_this_wave >= target_spawns_this_wave:
		# We’ve spawned enough; no more for this wave
		spawn_timer.stop()
		return

	_spawn_one_enemy()
	spawned_this_wave += 1

# --------------------------------------------
# ENEMY SPAWNING
# --------------------------------------------
func _spawn_one_enemy() -> void:
	var scene := _pick_enemy_for_wave(current_wave)
	if scene == null:
		return

	var enemy = scene.instantiate()

	# Get the CollisionShape2D node
	var collision_shape: CollisionShape2D = spawn_area.get_node("CollisionShape2D")
	if collision_shape.shape is RectangleShape2D:
		var rect_shape: RectangleShape2D = collision_shape.shape

		# Rectangle center in world space
		var rect_center: Vector2 = collision_shape.global_position

		# Random offset inside rectangle extents
		var offset_x := randf_range(-rect_shape.extents.x, rect_shape.extents.x)
		var offset_y := randf_range(-rect_shape.extents.y, rect_shape.extents.y)

		# Final position
		enemy.global_position = rect_center + Vector2(offset_x, offset_y)
	else:
		push_error("Spawn Area2D must have a RectangleShape2D shape")
		return

	add_child(enemy)


# Chooses a tier mix based on wave number; then picks a random enemy from that tier list.
func _pick_enemy_for_wave(wave: int) -> PackedScene:
	# Define tier weights per wave band
	var w1 := 0.0
	var w2 := 0.0
	var w3 := 0.0

	if wave <= 3:
		w1 = 1.0
	elif wave <= 6:
		w1 = 0.7; w2 = 0.3
	elif wave <= 9:
		w1 = 0.2; w2 = 0.6; w3 = 0.2
	else: # wave 10
		w1 = 0.0; w2 = 0.3; w3 = 0.7

	# If a tier is empty, push weight into lower tiers
	if enemy_tier3.is_empty(): w2 += w3; w3 = 0.0
	if enemy_tier2.is_empty(): w1 += w2; w2 = 0.0
	if enemy_tier1.is_empty():
		# Fallback: use any single list that has enemies (or return null)
		if not enemy_tier2.is_empty(): return enemy_tier2.pick_random()
		if not enemy_tier3.is_empty(): return enemy_tier3.pick_random()
		return null

	# Weighted pick of tier
	var roll := randf()
	var pick: Array[PackedScene]
	if roll < w1:
		pick = enemy_tier1
	elif roll < w1 + w2:
		pick = enemy_tier2
	else:
		pick = enemy_tier3

	if pick.is_empty():
		# Safety fallback
		pick = enemy_tier1
	return pick.pick_random()

# How many enemies to spawn in this wave, scaling by wave number and set progression
func _enemies_for_wave(wave: int, set_idx: int) -> int:
	var base := base_enemies_per_wave + enemies_growth_per_wave * (wave - 1)
	var set_scale := 1.0 + float(set_idx) * set_enemy_growth
	return int(round(base * set_scale))

# --------------------------------------------
# AFTER ALL WAVES
# --------------------------------------------
func _on_all_waves_completed() -> void:
	print("All waves complete! Set index:", set_index)

	# Advance persistent set progress if you track it
	if GameData.get("wave_set_index") != null:
		GameData.wave_set_index = set_index + 1
		GameData.save_game()
	set_index += 1

	emit_signal("all_waves_completed", set_index)

	# Call a hook method you can override OR do your end logic here:
	_after_waves_completed()

# Override this or edit body to do whatever you need (return to main scene, give rewards, etc.)
func _after_waves_completed() -> void:
	# Example: return to main scene
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
