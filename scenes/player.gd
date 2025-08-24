# player.gd
extends CharacterBody2D

@export var speed : int = 100
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var water_sprite: AnimatedSprite2D = $WaterSprite

@onready var rod: Sprite2D = $Rod
@onready var line: Line2D = $Rod/Line2D

@onready var cast_timer: Timer = $Timer
@onready var timer_2: Timer = $Timer2
@onready var bar_bar: TextureProgressBar = $BarBar
@onready var circle_bar: TextureProgressBar = $CircleBar
@onready var ui: Node2D = null
@onready var fish_sprite: Sprite2D = $FishSprite
@onready var hook: Sprite2D = $Rod/Hook
@onready var bar_filling_timer: Timer = $BarFillingTimer
@onready var bar_bar_filling_timer: Timer = $BarBarFillingTimer
@onready var ekey: Node2D = $Ekey
@onready var damage_flash: ColorRect = $ColorRect
@onready var camera: Camera2D = null
@onready var step_timer: Timer = $StepTimer
@onready var other_player: AudioStreamPlayer2D = $OtherPlayer
@export var cast_sound: AudioStream = preload("res://sounds/Retro Swooosh 07.wav")
@export var hurt_sound: AudioStream = preload("res://sounds/retro_die_01.ogg")
@export var drop_sound: AudioStream = preload("res://sounds/Retro Water Drop 01.wav")
@onready var water_particle: GPUParticles2D = $GPUParticles2D
@onready var walking_particle: GPUParticles2D = $WalkingParticle

@onready var footsteps: AudioStreamPlayer2D = $Footsteps

var rarity_difficulty := {
	"common": 1,
	"rare": 2,
	"epic": 3,
	"legendary": 4
}


# shake params
var shake_time: float = 0.0
var shake_intensity: float = 0.0
var original_camera_pos: Vector2


@export var casting_delay : float = 1.0
@export var water_block_radius: float = 6.0

var is_casting : bool = false   
var casted : bool = false    
var caught : bool = false  
var cast_target : Vector2 = Vector2.ZERO
var cast_speed : float = 600.0   
var rope_points : Array = []     
var rope_segments : int = 0
var max_health = GameData.health
var health = max_health
@export var segment_length : float = 10.0
@export var relaxation_iterations : int = 6

var min_bite_time = 1.0
var max_bite_time = 10.0
var retract_locked: bool = false

var current_speed = 5.0
var catching_speed = 5
var speed_change_timer = 0.0
var speed_change_interval = 0.1
var shop_opened = false
var in_water

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
	var root = get_tree().current_scene
	ui = root.get_node_or_null("UI")
	if ui == null:
		ui = root.find_child("UI", true, false) # recursive search
		print("⚠️ UI not found in scene!") if ui == null else print("✅ UI assigned")

	# Find Camera
	camera = root.get_node_or_null("Camera2D")
	if camera == null:
		camera = root.find_child("Camera2D", true, false)
		print("⚠️ Camera not found!") if camera == null else print("✅ Camera assigned")
	
	original_camera_pos = camera.position
	cast_timer.wait_time = casting_delay
	fishing_state = FishingState.IDLE
	_toggle_player_mode()

func _physics_process(delta):
	get_input()
	if get_tree().current_scene.get_node("World"): _check_water_state()

func _check_water_state():

	var world = get_tree().current_scene.get_node("World")  # adjust path if needed
	if not world:
		return

	var player_cell = world.tile_map.local_to_map(global_position)
	in_water = world.is_water_at(player_cell)

	if in_water:
		animated_sprite_2d.visible = false
		water_sprite.visible = true
		is_casting = false
		casted = false
	else:
		animated_sprite_2d.visible = true
		water_sprite.visible = false


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
		velocity = input_direction * GameData.walk_speed
	else:
		velocity = Vector2(0, 0)
		animated_sprite_2d.animation = "idle_front"
	if velocity != Vector2.ZERO:
		if step_timer.is_stopped():
			step_timer.start()
	
	if velocity != Vector2.ZERO:
		if step_timer.is_stopped():
			step_timer.start()
		# 🔥 Rotate particle opposite to movement
		walking_particle.rotation = velocity.angle() + PI
		walking_particle.emitting = true
	else:
		walking_particle.emitting = false
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_mode"):
		_toggle_player_mode()
		return
	
	if in_water: return

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
	if equipped_active_fish == null or in_water:
		return

	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()

	if equipped_active_fish.automatic:
		# Track holding for automatic shooting
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			equipped_active_fish.set_holding_fire(event.pressed)
	else:
		# Non-automatic shooting
		if event.is_action_pressed("click"):
			# Only start charging if fish supports charging
			if "is_charging" in equipped_active_fish:
				if not equipped_active_fish.is_charging:
					equipped_active_fish.is_charging = true
					equipped_active_fish.charge_time = 0.0
			else:
				if(equipped_active_fish._can_attack): SoundManager.play_shoot()
				equipped_active_fish.attack(fish_sprite.global_position, direction, self)

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# Release click: fire charged attack if applicable
			if "is_charging" in equipped_active_fish and equipped_active_fish.is_charging:
				equipped_active_fish.is_charging = false
				var power = clamp(1.0 + equipped_active_fish.charge_time * 3.0, 1.0, equipped_active_fish.max_charge * 3.0)
				if(equipped_active_fish._can_attack): SoundManager.play_shoot()
				equipped_active_fish.attack(fish_sprite.global_position, direction, self, true, power)

	# --- Right click (special ability) ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if equipped_active_fish.has_right_click:
			equipped_active_fish.right_click_effect(fish_sprite.global_position, direction, self)


func _toggle_player_mode() -> void:
	if(get_tree().current_scene.name == "FightScene"):
		return
	if player_mode == PlayerMode.FISHING && equipped_active_fish != null:
		player_mode = PlayerMode.COMBAT
		print("Switched to Combat Mode")
	else:
		player_mode = PlayerMode.FISHING
		print("Switched to Fishing Mode")
	changed_mode.emit()

func _start_catching_phase() -> void:
	if(!circle_bar.visible):
		_retract_rope()
		return
	print("CAUGHT!!!")
	SoundManager.play_click()
	bar_bar.visible = true
	bar_bar.value = circle_bar.value/5
	is_casting = false
	casted = false
	fish_to_catch = Fish_Manager.get_all_fish().pick_random().instantiate()
	fish_to_catch.setup_fish()
	fishing_state = FishingState.CATCHING_FISH
	bar_filling_timer.stop()
	circle_bar.visible = false
	timer_2.stop()
	bar_bar_filling_timer.start()

func _update_catching_phase() -> void:
	if bar_bar.visible:
		var rarity_value = rarity_difficulty.get(fish_to_catch.rarity, 1) # fallback = 1
		var increment = GameData.catching_speed - rarity_value * 2
		SoundManager.play_click()
		print("Increment: " + str(increment))
		bar_bar.value += increment
		bar_bar.value = clamp(bar_bar.value, 0, bar_bar.max_value)
		
	if bar_bar.value >= bar_bar.max_value:
		on_caught()
		bar_bar.value = bar_bar.max_value
		bar_bar.visible = false
		_retract_rope()
		fish_caught.emit(fish_to_catch)
		fishing_state = FishingState.IDLE
		bar_bar_filling_timer.stop()

func _handle_idle_click() -> void:
	if is_casting or casted:
		if circle_bar.visible:
			print("Progress bar stopped at:", circle_bar.value)
			circle_bar.visible = false
			bar_filling_timer.stop()
			bar_bar_filling_timer.start()
			bar_bar.visible = true
		else:
			is_casting = false
			casted = false
			circle_bar.visible = false
			_retract_rope()
			print("Didnt stop")
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
	other_player.stream = cast_sound
	other_player.play()

	_init_rope_from_to(Vector2(rod.position.x + 5, rod.position.y - 5), cast_target)

	line.clear_points()
	for p in rope_points:
		line.add_point(p)
	
	retract_locked = true
	await get_tree().create_timer(0.5).timeout
	retract_locked = false
	
func _retract_rope() -> void:
	if retract_locked:
		print("Retract is locked for now.")
		return

	fishing_state = FishingState.IDLE
	line.clear_points()
	rod.visible = false
	casted = false
	is_casting = false
	rope_points.clear()
	rope_segments = 0
	timer_2.stop()
	bar_bar_filling_timer.stop()
	bar_filling_timer.stop()
	


func _init_rope_from_to(start_pos : Vector2, target_pos : Vector2) -> void:
	var dist = start_pos.distance_to(target_pos)
	rope_segments = max(3, int(ceil(dist / segment_length)))
	rope_points.resize(rope_segments + 1)
	for i in range(rope_points.size()):
		rope_points[i] = start_pos


func _process(delta: float) -> void:
	if shake_time > 0.0:
		shake_time -= delta
		camera.position = original_camera_pos + Vector2(randf_range(-1,1), randf_range(-1,1)) * shake_intensity
	else:
		camera.position = original_camera_pos
	
	if equipped_active_fish != null:
		equipped_active_fish.process_automatic_fire(fish_sprite.global_position, get_global_mouse_position(), self)

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
		timer_2.wait_time = randf_range(min_bite_time, GameData.bite_time)
		timer_2.start()
		
		water_particle.position = cast_target
		water_particle.restart()  # ✅ this retriggers emission
		
		other_player.stream = drop_sound
		other_player.play()

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
	circle_bar.visible = true
	circle_bar.value = 0
	bar_filling_timer.start()

func _on_timer_tick():
	circle_bar.value += current_speed
	circle_bar.value = clamp(circle_bar.value, 0, circle_bar.max_value)
	speed_change_timer -= bar_filling_timer.wait_time
	if speed_change_timer <= 0:
		current_speed = randf_range(0.1, 4)  # min/max speed
		speed_change_timer = speed_change_interval
	if circle_bar.value >= circle_bar.max_value:
		circle_bar.visible = false
		print("Bar finished!")
		bar_filling_timer.stop()
		timer_2.start()


func on_caught():
	circle_bar.visible = false
	casted = false
	is_casting = false
	timer_2.stop()


func _on_bar_bar_filling_timer_timeout() -> void:
	if(bar_bar.value > 0):
		bar_bar.value -= 5
		bar_bar.value = clamp(bar_bar.value, 0, bar_bar.max_value)
	elif(bar_bar.visible) :
		bar_bar.visible = false
		_retract_rope()
		fishing_state = FishingState.IDLE
		bar_bar_filling_timer.stop()

func _on_hit_area_area_entered(body) -> void:
	# if player is dead, ignore
	if health <= 0:
		return

	# prevent self-hit
	if body.has_method("owner") and body.owner == self:
		return

	var dmg: int = 0

	# damage sources
	if body.has_method("get_damage"):
		dmg = int(body.get_damage())
	elif body.has_meta("damage"):
		dmg = int(body.get_meta("damage"))
	elif "damage" in body:
		dmg = int(body.damage)

	# apply damage
	if dmg > 0:
		take_damage(dmg)

		# notify projectile it hit something
		if body.has_method("on_hit"):
			body.on_hit(self)
		elif body.is_in_group("bullets"):
			body.queue_free()


func take_damage(amount: int, source: Node = null) -> void:
	if health <= 0:
		return
	other_player.stream = hurt_sound
	other_player.play()
	health -= floor(amount * GameData.enemy_damage)
	GameData.health = health  # per-player health if using co-op

	_flash_screen()
	_start_camera_shake(0.2, 6)  # 0.2s shake, 6px intensity

	if health <= 0:
		health = 0
		die()

# --- Flash screen ---
func _flash_screen():
	if not damage_flash:
		return
	damage_flash.visible = true
	damage_flash.modulate.a = 0.6

	var tween = create_tween()
	tween.tween_property(damage_flash, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.connect("finished", Callable(damage_flash, "hide"))

# --- Camera shake ---
func _start_camera_shake(duration: float, intensity: float):
	shake_time = duration
	shake_intensity = intensity
	original_camera_pos = camera.position

func die() -> void:
	set_process(false)
	set_physics_process(false)
	
	var tween := create_tween()
	tween.tween_property(animated_sprite_2d, "rotation_degrees", 720, 0.6)
	tween.tween_property(animated_sprite_2d, "position:y", position.y + 120, 0.6)
	tween.tween_property(animated_sprite_2d, "modulate:a", 0.0, 0.6)

	
	await tween.finished
	get_tree().paused = true

	var death_screen_scene = preload("res://scenes/game_over.tscn")
	var death_screen = death_screen_scene.instantiate()
	get_tree().current_scene.add_child(death_screen)

func _on_house_show_e() -> void:
	ekey.visible = true
	print("HOUSE ENTERED")


func _on_house_hide_e() -> void:
	ekey.visible = false


func _on_house_interacted() -> void:
	if(!shop_opened):
		ui.shop_ui._update_coin_label()
		ui.shop_ui.visible = true
		shop_opened = true
	elif(shop_opened):
		ui.shop_ui.visible = false
		shop_opened = false


func _on_timer_timeout() -> void:
	is_casting = false
	casted = false


func _on_step_timer_timeout() -> void:
	footsteps.play()
