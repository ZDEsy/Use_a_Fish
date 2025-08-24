extends FishNode

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")

	# First bullet
	var center_bullet = bullet_scene.instantiate()
	center_bullet.global_position = position
	center_bullet.direction = direction.rotated(deg_to_rad(randf_range(-spread_degrees, spread_degrees)))
	center_bullet.damage = damage
	center_bullet.speed = bullet_speed
	center_bullet.lifetime = bullet_lifetime
	if owner and owner.get_parent():
		owner.get_parent().add_child(center_bullet)

	# Wait 0.1s before spawning side bullets
	await owner.get_tree().create_timer(0.05).timeout

	var offset_dist: float = 10.0
	var perp := direction.normalized().orthogonal()

	var left_bullet = bullet_scene.instantiate()
	left_bullet.global_position = position + perp * offset_dist
	left_bullet.direction = direction.rotated(deg_to_rad(randf_range(-spread_degrees, spread_degrees)))
	left_bullet.damage = damage
	left_bullet.speed = bullet_speed
	left_bullet.lifetime = bullet_lifetime
	owner.get_parent().add_child(left_bullet)

	var right_bullet = bullet_scene.instantiate()
	right_bullet.global_position = position - perp * offset_dist
	right_bullet.direction = direction.rotated(deg_to_rad(randf_range(-spread_degrees, spread_degrees)))
	right_bullet.damage = damage
	right_bullet.speed = bullet_speed
	right_bullet.lifetime = bullet_lifetime
	owner.get_parent().add_child(right_bullet)
