extends FishNode

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack: # need at least 4 bullets
		return

	_can_attack = false
	shoot_wave(position, direction, owner)

	# wait for cooldown before allowing next attack
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true


func shoot_wave(position: Vector2, direction: Vector2, owner: Node) -> void:
	var bullet_scene := preload("res://scenes/Bullet.tscn")

	# fire 4 bullets with small delay and angle offset
	for i in range(4):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = position

		# Apply angled wave spread (e.g., +5° per bullet)
		var spread_rad = deg_to_rad(i * 5.0) # adjust spacing angle here
		bullet.direction = direction.rotated(spread_rad)

		bullet.damage = damage
		bullet.speed = bullet_speed
		bullet.lifetime = bullet_lifetime

		if owner and owner.get_parent():
			owner.get_parent().add_child(bullet)

		# delay before next bullet
		if i < 3: # no delay after last one
			await owner.get_tree().create_timer(0.1).timeout
