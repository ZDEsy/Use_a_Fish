extends Bullet

@export var deceleration: float = 1000.0  # units per second²

func _physics_process(delta: float) -> void:
	speed = max(0, speed - deceleration * delta)
	print(speed)
	super._physics_process(delta)
