extends FishNode

var first_bullet = true 
func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	# Define angles for arrow pattern (middle is 0, sides slightly back)
	var angles = [0, deg_to_rad(-4), deg_to_rad(4)]  # adjust side angles as needed

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
		
		if owner and owner.get_tree() and first_bullet:
			await owner.get_tree().create_timer(0.1).timeout
			first_bullet = false

	_can_attack = false
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
		first_bullet = true
	else:
		_can_attack = true
