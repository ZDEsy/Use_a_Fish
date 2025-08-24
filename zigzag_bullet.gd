extends Bullet

@export var zigzag_amplitude: float = 30.0  # how far left/right
@export var zigzag_frequency: float = 8.0   # how fast it wiggles

var _time_alive: float = 0.0

func _process(delta: float) -> void:
	# side-to-side oscillation
	var perpendicular := direction.orthogonal().normalized()
	var offset = sin(_time_alive * zigzag_frequency) * zigzag_amplitude
	global_position += (direction.normalized() * speed + perpendicular * offset) * delta

	# lifetime
	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()
