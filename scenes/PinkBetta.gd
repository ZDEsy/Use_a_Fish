extends FishNode

var first_bullet = 0

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	# Define angles for arrow pattern
	var angles = [0, deg_to_rad(-4), deg_to_rad(4), deg_to_rad(-8), deg_to_rad(8)]

	var bullet_scene := preload("res://scenes/Bullet.tscn")

	for angle in angles:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = position
		bullet.direction = direction.rotated(angle)
		bullet.damage = damage
		bullet.speed = bullet_speed
		bullet.lifetime = bullet_lifetime

		if owner and owner.get_parent():
			owner.get_parent().add_child(bullet)

		# Delay only for first or third bullet
		if owner and owner.get_tree() and (first_bullet == 0 or first_bullet == 2):
			await owner.get_tree().create_timer(0.1).timeout

		first_bullet += 1

	_can_attack = false
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
		first_bullet = 0
	else:
		_can_attack = true
		first_bullet = 0 
