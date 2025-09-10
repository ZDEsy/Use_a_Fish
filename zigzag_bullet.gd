extends Bullet

@export var zigzag_amplitude: float = 5.0   # distance left/right
@export var zigzag_frequency: float = 2.0   # oscillations per second

var _time_alive: float = 0.0
var _forward_pos: Vector2

func _ready() -> void:
	_forward_pos = global_position

func _process(delta: float) -> void:
	_time_alive += delta

	# Step forward incrementally
	_forward_pos += direction.normalized() * speed * delta

	# Smooth zigzag with sine wave
	var perpendicular: Vector2 = direction.orthogonal().normalized()
	var offset: float = sin(_time_alive * zigzag_frequency * TAU) * zigzag_amplitude

	# Apply both
	global_position = _forward_pos + perpendicular * offset

	# Lifetime check
	if _time_alive >= lifetime:
		queue_free()
