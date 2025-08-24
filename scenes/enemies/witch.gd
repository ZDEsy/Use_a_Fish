extends Enemy

@export var projectile_scene: PackedScene
@onready var throw_timer: Timer = $throwTimer

func _ready():
	anim_controller.animations = {
		"idle": "idle",
		"run": "run",
		"attack": "attack",
		"die": "die",
	}
	super._ready()

func _play_throw() -> void:
	state = State.ATTACK
	anim_controller.play("attack")
	throw_timer.start()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	if not player:
		return

	if state == State.ATTACK:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance <= attack_range:
		velocity = Vector2.ZERO
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = attack_cooldown
			_play_throw()
		else:
			if state != State.ATTACK:
				state = State.IDLE
	else:
		if state != State.ATTACK:
			state = State.RUN
			var dir = to_player.normalized()
			velocity = dir * speed
			move_and_slide()
			_face_direction(dir)

	_update_animation()


func _on_throw_timer_timeout() -> void:
	if not projectile_scene:
		return
	var projectile = projectile_scene.instantiate()
	projectile.shooter = self
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.direction = (player.global_position - global_position).normalized()
