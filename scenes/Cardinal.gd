extends FishNode

var _sprinkler_angle: float = 0.0   # keeps track of the current rotation angle

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	# preload bullet
	var bullet_scene := preload("res://scenes/Bullet.tscn")

	# rotate direction like a sprinkler
	var sprinkler_dir = Vector2.RIGHT.rotated(_sprinkler_angle)

	# spawn bullet
	var bullet = bullet_scene.instantiate()
	bullet.global_position = position
	bullet.direction = sprinkler_dir
	bullet.damage = damage
	bullet.speed = bullet_speed
	bullet.lifetime = bullet_lifetime

	if owner and owner.get_parent():
		owner.get_parent().add_child(bullet)

	# 🔄 increase sprinkler angle for next bullet
	_sprinkler_angle += deg_to_rad(20)  # 20° per shot, tweak for faster/slower rotation
	if _sprinkler_angle >= TAU: # TAU = 2*PI, full circle
		_sprinkler_angle = 0.0

	# cooldown logic
	_can_attack = false
	if owner and owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true
