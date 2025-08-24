extends FishNode

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/zigzag_bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = position

	# Apply spread
	var spread_rad = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	bullet.direction = direction.rotated(spread_rad)

	# bullet setup
	bullet.damage = damage
	bullet.speed = bullet_speed
	bullet.lifetime = bullet_lifetime
	bullet.zigzag_amplitude = 25.0
	bullet.zigzag_frequency = 10.0

	if owner and owner.get_parent():
		owner.get_parent().add_child(bullet)

	_can_attack = false
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true
