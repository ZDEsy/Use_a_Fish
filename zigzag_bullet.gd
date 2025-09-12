extends Bullet

@export var zigzag_amplitude: float = 0.5   # distance left/right
@export var zigzag_frequency: float = 0.5   # oscillations per second

var _time_alive: float = 0.0
var _forward_pos: Vector2

func _ready() -> void:
	_forward_pos = global_position
	super._ready()

func _process(delta: float) -> void:
	_time_alive += delta

	# Step forward incrementally
	_forward_pos += direction.normalized() * speed * delta

	# Smooth zigzag with sine wave based on distance traveled
	var distance_traveled = _time_alive * speed
	var perpendicular: Vector2 = direction.orthogonal().normalized()

	# offset oscillates smoothly over distance
	var offset: float = sin(distance_traveled / zigzag_frequency) * zigzag_amplitude

	# Apply both
	global_position = _forward_pos + perpendicular * offset

	# Lifetime check
	if _time_alive >= lifetime:
		queue_free()
