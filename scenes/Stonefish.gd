extends FishNode

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")

	# number of triangle spreads around the player (higher = denser circle)
	var triangle_count := 36  # 36 * 3 bullets = 108 bullets
	var angle_step := TAU / triangle_count  # TAU = 2 * PI radians (360°)

	for i in range(triangle_count):
		# base angle for this triangle
		var angle = i * angle_step
		var dir = Vector2.RIGHT.rotated(angle)

		# make small offset so the triangle bullets are close
		var offset_dist: float = 6.0  
		var perp := dir.orthogonal()

		# --- center bullet ---
		var center_bullet = bullet_scene.instantiate()
		center_bullet.global_position = position
		center_bullet.direction = dir
		center_bullet.damage = damage * 0.5   # weaker per bullet
		center_bullet.speed = bullet_speed
		center_bullet.lifetime = bullet_lifetime
		center_bullet.scale *= 0.3  # make them extra small
		owner.get_parent().add_child(center_bullet)

		# --- left bullet ---
		var left_bullet = bullet_scene.instantiate()
		left_bullet.global_position = position + perp * offset_dist
		left_bullet.direction = dir
		left_bullet.damage = damage * 0.5
		left_bullet.speed = bullet_speed
		left_bullet.lifetime = bullet_lifetime
		left_bullet.scale *= 0.3
		owner.get_parent().add_child(left_bullet)

		# --- right bullet ---
		var right_bullet = bullet_scene.instantiate()
		right_bullet.global_position = position - perp * offset_dist
		right_bullet.direction = dir
		right_bullet.damage = damage * 0.5
		right_bullet.speed = bullet_speed
		right_bullet.lifetime = bullet_lifetime
		right_bullet.scale *= 0.3
		owner.get_parent().add_child(right_bullet)

	# cooldown
	_can_attack = false
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true
