extends FishNode

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = position

	# Apply spread
	var spread_rad = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	bullet.direction = direction.rotated(spread_rad)

	bullet.damage = damage
	bullet.speed = bullet_speed
	bullet.lifetime = bullet_lifetime

	# 🔹 Scale down bullet visuals and hitbox
	if bullet.has_node("Sprite2D"):
		bullet.get_node("Sprite2D").scale *= 0.5   # make sprite 50% smaller
	if bullet.has_node("CollisionShape2D"):
		bullet.get_node("CollisionShape2D").scale *= 0.5   # make hitbox match

	if owner and owner.get_parent():
		owner.get_parent().add_child(bullet)

	_can_attack = false
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true
