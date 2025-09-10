extends Enemy

@onready var arena_area: Area2D
@export var wander_speed: float = 60.0
@export var wander_change_interval: float = 2.0
@export var wander_mode: bool = false
var _wander_timer: float = 0.0
var _wander_direction: Vector2 = Vector2.ZERO

func _ready():
	anim_controller.animations = {
		"run": "run",
		"attack": "attack",
		"die": "die"
	}
	
	if get_tree().current_scene.has_node("Area2D"):
		arena_area = get_tree().current_scene.get_node("Area2D")
		wander_mode = true
	else:
		wander_mode = false

	super._ready()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	if not player:
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance <= attack_range:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = attack_cooldown
			_play_attack()
		else:
			if state != State.ATTACK:
				state = State.IDLE
	else:
		if state != State.ATTACK:
			state = State.RUN
			_wander_timer -= delta
			if _wander_timer <= 0.0:
				# Pick new random direction
				_wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
				_wander_timer = wander_change_interval
			velocity = _wander_direction * wander_speed
			move_and_slide()
	_stay_inside_arena()
	# Flip
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
	_update_animation()

func _stay_inside_arena() -> void:
	if not arena_area:
		return
	var shape = arena_area.get_node("CollisionShape2D").shape

	if shape is CircleShape2D:
		var max_dist = shape.radius
		var to_center = global_position - arena_area.global_position
		if to_center.length() > max_dist:
			# turn back toward center
			_wander_direction = (-to_center).normalized()

	elif shape is RectangleShape2D:
		var rect = Rect2(
			arena_area.global_position - shape.extents,
			shape.extents * 2.0
		)
		if not rect.has_point(global_position):
			_wander_direction = (arena_area.global_position - global_position).normalized()


func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite_2d.animation == "attack" and animated_sprite_2d.frame == 7: # <-- frame where hit connects
		_attack_hit()

func _update_animation() -> void:
	# Flip depending on direction
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
	
	super._update_animation()
