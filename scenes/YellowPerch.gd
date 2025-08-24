extends FishNode

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")

	# perpendicular vector (for left/right offset)
	var perp := direction.normalized().orthogonal()
	var offset_dist: float = 10.0  # distance between the two bullets

	for side in [-1, 1]:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = position + perp * offset_dist * side

		# Apply spread
		var spread_rad = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
		bullet.direction = direction.rotated(spread_rad)

		bullet.damage = damage
		bullet.speed = bullet_speed
		bullet.lifetime = bullet_lifetime

		if owner and owner.get_parent():
			owner.get_parent().add_child(bullet)

	_can_attack = false
	await owner.get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true
