extends FishNode

var shoot_big: bool = false   # toggle between normal and big shots


func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = position
	bullet.direction = direction

	# Alternate between normal and big
	if shoot_big:
		bullet.scale = Vector2(0.5, 0.5)     # bigger bullet
		bullet.damage = damage * 2           # stronger
		bullet.speed = bullet_speed * 0.8    # maybe a bit slower
	else:
		bullet.scale = Vector2(0.2, 0.2)         # normal size
		bullet.damage = damage
		bullet.speed = bullet_speed

	bullet.lifetime = bullet_lifetime

	if owner and owner.get_parent():
		owner.get_parent().add_child(bullet)

	# Flip toggle for next shot
	shoot_big = not shoot_big

	_can_attack = false
	if owner.get_tree():
		await owner.get_tree().create_timer(attack_cooldown).timeout
		_can_attack = true
	else:
		_can_attack = true
