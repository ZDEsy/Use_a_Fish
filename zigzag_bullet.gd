extends Bullet

@export var zigzag_amplitude: float = 30.0   # distance left/right
@export var zigzag_frequency: float = 4.0    # switches per second

var _time_alive: float = 0.0
var _start_position: Vector2

func _ready() -> void:
	_start_position = global_position

func _process(delta: float) -> void:
	_time_alive += delta

	# Forward motion
	var forward: Vector2 = direction.normalized() * speed * _time_alive

	# Sharp side-to-side: square wave instead of sine
	var perpendicular: Vector2 = direction.orthogonal().normalized()
	var side_sign: float = sign(sin(_time_alive * zigzag_frequency * TAU)) # +1.0 or -1.0
	var offset: float = side_sign * zigzag_amplitude

	# Apply both
	global_position = _start_position + forward + perpendicular * offset

	# Lifetime check
	if _time_alive >= lifetime:
		queue_free()
