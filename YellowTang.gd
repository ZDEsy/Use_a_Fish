extends FishNode


func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")
	var dir = direction.normalized()

	# 4 bullets in star/X shape
	var angles = [0.0, PI/2, PI, 3*PI/2]  # radians

	for angle in angles:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = position
		bullet.direction = dir.rotated(angle)
		bullet.damage = damage
		bullet.speed = bullet_speed
		bullet.lifetime = bullet_lifetime

		if owner and owner.get_parent():
			owner.get_parent().add_child(bullet)

	_can_attack = false
	if owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true
