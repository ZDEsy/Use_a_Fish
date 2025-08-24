extends FishNode

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = position

	# Apply spread and flip backwards (180°)
	var spread_rad = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	bullet.direction = direction.rotated(PI).rotated(spread_rad)

	bullet.damage = damage
	bullet.speed = bullet_speed
	bullet.lifetime = bullet_lifetime

	if owner and owner.get_parent():
		owner.get_parent().add_child(bullet)

	_can_attack = false
	await owner.get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true

func process_automatic_fire(global_pos: Vector2, global_mouse_position: Vector2, owner) -> void:
	if automatic and _holding_fire and _can_attack:
		var mouse_pos = global_mouse_position
		var direction = (mouse_pos - global_pos).normalized()

		# Flip backwards (180°)
		direction = direction.rotated(PI)

		if _can_attack:
			SoundManager.play_shoot()
		attack(global_pos, direction, owner)
