extends Bullet
class_name ShieldBullet

# Disable movement/lifetime — shield orbit is handled externally
func _ready():
	# Don't let parent timer auto-destroy
	if timer:
		timer.stop()

	# Optional: make shield bullets look bigger / spin differently
	rotation_speed = 0.0
	speed = 0.0

	# If you want particles, still emit
	if flash:
		flash.emitting = true

# Override movement so it doesn't fly off
func _physics_process(_delta):
	# orbit is managed by FishNode, do nothing here
	pass

# Optional: shield bullet should not die on hit, but block instead
func on_hit(target: Node) -> void:
	# Example: destroy itself OR absorb the hit
	queue_free()
