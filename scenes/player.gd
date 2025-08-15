# player.gd
extends CharacterBody2D

@export var speed : int = 100
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var rod: Sprite2D = $Rod
@onready var line: Line2D = $Rod/Line2D

@onready var cast_timer: Timer = $Timer
@onready var timer_2: Timer = $Timer2
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var progress_bar_2: ProgressBar = $ProgressBar2
@onready var ui: Node2D = $UI
@onready var fish_sprite: Sprite2D = $FishSprite
@onready var hook: Sprite2D = $Rod/Hook
@export var casting_delay : float = 1.0
@export var water_block_radius: float = 6.0

var is_casting : bool = false   
var casted : bool = false    
var caught : bool = false  
var cast_target : Vector2 = Vector2.ZERO
var cast_speed : float = 600.0   
var rope_points : Array = []     
var rope_segments : int = 0
@export var segment_length : float = 10.0
@export var relaxation_iterations : int = 6

var min_bite_time = 1.0
var max_bite_time = 10.0

var current_speed = 10.0
var speed_change_timer = 0.0
var speed_change_interval = 0.1

signal fish_caught(fish)
signal changed_mode
var fish_to_catch
var equipped_active_fish

enum PlayerMode {
	FISHING,
	COMBAT
}

var player_mode = PlayerMode.FISHING

enum FishingState {
	IDLE,
	WAITING_FOR_FISH,
	CATCHING_FISH
}

var fishing_state = FishingState.IDLE

func _ready():
	cast_timer.wait_time = casting_delay

func _physics_process(delta):
	get_input()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if(not casted and not is_casting):
		if input_direction.x < 0:
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.animation = "run_side"
		elif input_direction.x > 0:
			animated_sprite_2d.animation = "run_side"
			animated_sprite_2d.flip_h = false
		elif input_direction.y < 0:
			animated_sprite_2d.animation = "run_back"
		elif input_direction.y > 0:
			animated_sprite_2d.animation = "run_front"
		else:
			animated_sprite_2d.animation = "idle_front"
		velocity = input_direction * speed
	else:
		velocity = Vector2(0, 0)
		animated_sprite_2d.animation = "idle_front"
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_mode"):
		_toggle_player_mode()
		return

	match player_mode:
		PlayerMode.FISHING:
			_handle_fishing_input(event)
		PlayerMode.COMBAT:
			_handle_combat_input(event)

func _handle_fishing_input(event: InputEvent) -> void:
	if not event.is_action_pressed("click"):
		return

	match fishing_state:
		FishingState.WAITING_FOR_FISH:
			_start_catching_phase()

		FishingState.CATCHING_FISH:
			_update_catching_phase()

		FishingState.IDLE:
			_handle_idle_click()

func _handle_combat_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - global_position).normalized()
		if equipped_active_fish != null:
			equipped_active_fish.attack(global_position, direction, self)

func _toggle_player_mode() -> void:
	if player_mode == PlayerMode.FISHING:
		player_mode = PlayerMode.COMBAT
		print("Switched to Combat Mode")
	else:
		player_mode = PlayerMode.FISHING
		print("Switched to Fishing Mode")
	changed_mode.emit()

func _start_catching_phase() -> void:
	if(!progress_bar.visible):
		_handle_idle_click()
		return
	print("CAUGHT!!!")
	progress_bar_2.value = 20
	progress_bar_2.visible = true
	progress_bar.visible = false
	is_casting = false
	casted = false
	fish_to_catch = Fish_Manager.get_all_fish().pick_random().instantiate()
	fish_to_catch.setup_fish()
	fishing_state = FishingState.CATCHING_FISH

func _update_catching_phase() -> void:
	progress_bar_2.value += (15 - fish_to_catch.difficulty * 2)
	print(fish_to_catch.fish_name)
	if progress_bar_2.value >= 100:
		_retract_rope()
		progress_bar_2.value = 0
		fish_caught.emit(fish_to_catch)
		fishing_state = FishingState.IDLE

func _handle_idle_click() -> void:
	if is_casting or casted:
		if progress_bar.visible:
			print("Progress bar stopped at:", progress_bar.value)
			progress_bar.visible = false
		else:
			is_casting = false
			casted = false
			progress_bar.visible = false
			_retract_rope()
	else:
		cast_on_click()
		fishing_state = FishingState.WAITING_FOR_FISH

func cast_on_click():
	if not cast_timer.is_stopped():
		print("Cast on cooldown: ", cast_timer.time_left, "s left")
		return

	var mouse_global : Vector2 = get_global_mouse_position()
	var mouse_local : Vector2 = get_local_mouse_position()
	var world_node = $"../World"
	var tile_map_node := world_node.get_node("TileMap") if world_node.has_node("TileMap") else null
	if tile_map_node == null:
		print("Warning: tilemap node not found under world node; allow cast by default")
	else:
		var local_pos : Vector2 = tile_map_node.to_local(mouse_global)
		var cell : Vector2i = tile_map_node.local_to_map(local_pos)
		if not world_node.is_water_at(cell):
			print("You can only cast on water tiles. That tile is not water.")
			return

	rod.visible = true
	casted = true
	is_casting = true
	cast_target = mouse_local

	_init_rope_from_to(Vector2(rod.position.x + 5, rod.position.y - 5), cast_target)

	line.clear_points()
	for p in rope_points:
		line.add_point(p)
	
func _retract_rope() -> void:
	line.clear_points()
	rod.visible = false
	casted = false
	is_casting = false
	rope_points.clear()
	rope_segments = 0
	cast_timer.start()
	timer_2.stop()

func _init_rope_from_to(start_pos : Vector2, target_pos : Vector2) -> void:
	var dist = start_pos.distance_to(target_pos)
	rope_segments = max(3, int(ceil(dist / segment_length)))
	rope_points.resize(rope_segments + 1)
	for i in rope_points.size():
		rope_points[i] = start_pos


func _process(delta: float) -> void:
	if(progress_bar_2.value > 0):
		progress_bar_2.value -= current_speed * delta
	elif(progress_bar_2.visible) :
		progress_bar_2.visible = false
		_retract_rope()
	
	if progress_bar.visible:
		progress_bar.value += current_speed * delta
		speed_change_timer -= delta
		if speed_change_timer <= 0:
			current_speed = randf_range(-10, 70)  # min/max speed
			speed_change_timer = speed_change_interval
		if progress_bar.value >= progress_bar.max_value:
			progress_bar.visible = false
			print("Bar finished!")

	if rope_points.size() == 0:
		return

	rope_points[0] = Vector2(rod.position.x + 5, rod.position.y - 5)

	if is_casting:
		var last_idx = rope_points.size() - 1
		var towards = (cast_target - rope_points[last_idx])
		var move_amount = cast_speed * delta
		if towards.length() <= move_amount:
			rope_points[last_idx] = cast_target
		else:
			rope_points[last_idx] += towards.normalized() * move_amount

	elif casted:
		var last_idx = rope_points.size() - 1
		var sway_dir = (cast_target - rope_points[last_idx])
		rope_points[last_idx] += sway_dir * 0.02 * delta

	for iter in range(relaxation_iterations):
		rope_points[0] = Vector2(rod.position.x + 5, rod.position.y - 5)

		for i in range(rope_points.size() - 1):
			var p1 : Vector2 = rope_points[i]
			var p2 : Vector2 = rope_points[i + 1]
			var delta_vec : Vector2 = p2 - p1
			var dist : float = delta_vec.length()
			if dist == 0:
				continue
			var diff : float = (dist - segment_length) / dist
			if i == 0:
				rope_points[i + 1] = p2 - delta_vec * diff
			else:
				rope_points[i] = p1 + delta_vec * 0.5 * diff
				rope_points[i + 1] = p2 - delta_vec * 0.5 * diff

	var last_index = rope_points.size() - 1
	if is_casting and rope_points[last_index].distance_to(cast_target) < 2.0:
		is_casting = false
		cast_timer.start()
		timer_2.wait_time = randf_range(min_bite_time, max_bite_time)
		timer_2.start()

	if line.get_point_count() != rope_points.size():
		line.clear_points()
		for p in rope_points:
			line.add_point(p)
	else:
		for i in range(rope_points.size()):
			line.set_point_position(i, rope_points[i])
	
	if rope_points.size() > 0:
		hook.position = Vector2(rope_points[last_index].x - 10, rope_points[last_index].y)
		if rope_points.size() >= 2:
			var prev_point = rope_points[last_index - 1]
			hook.rotation = (rope_points[last_index] - prev_point).angle()

func _on_timer_2_timeout() -> void:
	progress_bar.visible = true
	progress_bar.value = 0


func on_caught():
	progress_bar.visible = false
	casted = false
	is_casting = false
	timer_2.stop()
