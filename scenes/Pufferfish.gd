extends FishNode

func right_click_effect(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not has_right_click or not _can_right_click:
		return
	if not owner:
		return

	# Load and spawn bullet
	var bullet_scene := preload("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = position
	bullet.direction = direction

	# Make it stronger and bigger
	var big_scale := 2.0  # 👈 adjust this multiplier as you like
	bullet.damage = damage * big_scale
	bullet.speed = bullet_speed * 1.2   # slightly faster if you want
	bullet.lifetime = bullet_lifetime
	bullet.scale = Vector2(0.2, 0.2) * big_scale  # assumes 0.2 is original

	# Scale the collision radius too
	if bullet.has_node("CollisionShape2D"):
		var col_shape: CollisionShape2D = bullet.get_node("CollisionShape2D")
		if col_shape.shape is CircleShape2D:
			col_shape.shape.radius *= big_scale

	# Add to scene
	if owner and owner.get_parent():
		owner.get_parent().add_child(bullet)

	# Cooldown
	_can_right_click = false
	if owner.get_tree():
		await owner.get_tree().create_timer(right_click_cooldown).timeout
		_can_right_click = true
	else:
		_can_right_click = true
