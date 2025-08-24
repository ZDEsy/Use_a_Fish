extends FishNode



func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")

	# normalize direction to avoid scaling issues
	var dir = direction.normalized()

	# angles for spread (in radians)
	var spread_angle := 0.2  # ~11.5 degrees
	var angles = [0.0, -spread_angle, spread_angle]

	for angle in angles:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = position

		# Rotate the direction vector by angle
		bullet.direction = dir.rotated(angle)

		bullet.damage = damage
		
		bullet.speed = bullet_speed
		bullet.lifetime = bullet_lifetime

		if owner and owner.get_parent():
			owner.get_parent().add_child(bullet)

	# cooldown
	_can_attack = false
	if owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true
