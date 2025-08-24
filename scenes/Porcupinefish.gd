extends FishNode

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")

	# Random number of bullets between 5 and 10
	var num_bullets = randi_range(5, 10)

	for i in range(num_bullets):

		var bullet = bullet_scene.instantiate()
		bullet.global_position = position

		# Evenly spread bullets in a circle
		var angle = (TAU / num_bullets) * i  # TAU = 2*PI (full circle)
		bullet.direction = Vector2.RIGHT.rotated(angle)  # start from right, rotate

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
