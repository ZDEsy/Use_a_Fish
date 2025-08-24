extends FishNode

@export var pellets: int = 5              # how many bullets per shot
@export var spread_angle: float = 30.0    # total spread cone in degrees

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")

	# Calculate angle step between pellets
	var angle_step = 0.0
	if pellets > 1:
		angle_step = spread_angle / float(pellets - 1)

	# Start angle so the spread is centered around the aim direction
	var start_angle = -spread_angle / 2.0

	for i in range(pellets):

		var bullet = bullet_scene.instantiate()
		bullet.global_position = position

		var angle_offset = deg_to_rad(start_angle + i * angle_step)
		bullet.direction = direction.rotated(angle_offset)

		bullet.damage = damage
		bullet.speed = bullet_speed
		bullet.lifetime = bullet_lifetime

		if owner and owner.get_parent():
			owner.get_parent().add_child(bullet)

	# Cooldown
	_can_attack = false
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true
