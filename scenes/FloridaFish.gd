extends FishNode

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/slowing_bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = position

	# Apply spread
	var spread_rad = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	bullet.direction = direction.rotated(spread_rad)

	# Setup bullet stats
	bullet.damage = damage
	bullet.speed = bullet_speed   # starting speed
	bullet.lifetime = bullet_lifetime

	if owner and owner.get_parent():
		owner.get_parent().add_child(bullet)

	_can_attack = false
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true
