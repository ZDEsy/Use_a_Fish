extends Enemy

@export var roll_speed: float = 100.0
@export var roll_duration: float = 0.2
@export var roll_chance: float = 0.01  # probability each frame to trigger a roll

var _roll_timer: float = 0.0
var _roll_direction: Vector2 = Vector2.ZERO

func _ready():
	anim_controller.animations = {
		"idle": "idle",
		"run": "run",
		"attack": "attack",
		"die": "die",
		"roll": "roll"
	}
	super._ready()


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	
	if state == State.ROLL:
		velocity = _roll_direction * roll_speed
		move_and_slide()  # respects arena walls
		_roll_timer -= delta
		if _roll_timer <= 0:
			state = State.IDLE
		return

	# Normal enemy logic here...
	super._physics_process(delta)

	# Random chance to roll (only if not attacking)
	if state in [State.IDLE, State.RUN] and randf() < roll_chance:
		_start_roll()



func _start_roll():
	state = State.ROLL
	_roll_timer = roll_duration
	velocity = Vector2.ZERO  # clear old velocity

	# choose direction (towards player, away, random cone etc.)
	if player:
		_roll_direction = (player.global_position - global_position).normalized()
	else:
		_roll_direction = Vector2.RIGHT

	anim_controller.play("roll")
