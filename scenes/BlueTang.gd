extends FishNode

@export var bullet_spacing: float = 5.0  # distance between bullets

func attack(position: Vector2, direction: Vector2, owner: Node) -> void:
	if not _can_attack:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")
	var dir = direction.normalized()

	# spawn 3 bullets close behind each other
	for i in range(3):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = position - dir * bullet_spacing * i  # shift back
		bullet.direction = dir
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
